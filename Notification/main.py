"""
Teeth Management Notification Service
FastAPI microservice for Firebase Cloud Messaging (FCM) notifications
with support for templates, multi-language, idempotency, and delivery tracking

Location: Notification/main.py
Port: 9000
Created: April 4, 2026
"""

from fastapi import FastAPI, HTTPException, Header, Depends
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import logging
import sys
import os
from datetime import datetime, timezone
from sqlalchemy import text, Sequence
from sqlalchemy.orm import Session
from models.schemas import DeviceTokenRequest
# Utility for timezone-aware UTC time
def utc_now():
    """Return current UTC time as timezone-aware datetime"""
    return datetime.now(timezone.utc)

from apscheduler.schedulers.background import BackgroundScheduler
import atexit

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(__file__))

from config import get_db_session, init_firebase
from routes.notification_routes import router as notification_router
from routes.patient_routes import router as patient_router
from utils.logger import setup_logger

# Initialize logging
logger = setup_logger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Teeth Management Notification Service",
    version="1.0.0",
    description="Advanced notification service with FCM, templates, multi-language, and delivery tracking"
)

# Enable CORS (for Java backend calling from different port)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Firebase on startup
@app.on_event("startup")
async def startup_event():
    try:
        init_firebase()
        logger.info("Firebase initialized successfully on startup")
        
        # Start background queue processor
        from services.queue_service import QueueService
        
        def process_notifications():
            """Background task to process notification queue"""
            try:
                db = next(get_db_session())
                queue_service = QueueService(db)
                queue_service.process_queue(db)
                db.close()
            except Exception as e:
                logger.error(f"Background queue processor error: {e}")
        
        # Initialize APScheduler
        scheduler = BackgroundScheduler()
        scheduler.add_job(process_notifications, 'interval', seconds=2)
        
        # Add job to cleanup expired patient tokens (every hour)
        def cleanup_patient_tokens():
            """Background task to cleanup expired patient tokens"""
            try:
                from services.patient_token_service import PatientTokenService
                db = next(get_db_session())
                token_service = PatientTokenService(db)
                deleted = token_service.cleanup_expired_tokens()
                db.close()
            except Exception as e:
                logger.error(f"Patient token cleanup error: {e}")
        
        scheduler.add_job(cleanup_patient_tokens, 'interval', hours=1)
        
        scheduler.start()
        logger.info("Background notification queue processor started (runs every 2 seconds)")
        logger.info("Patient token cleanup started (runs every hour)")
        
        # Shutdown handler
        atexit.register(lambda: scheduler.shutdown())
        
    except Exception as e:
        logger.error(f"Failed to initialize Firebase: {e}")
        logger.error("Exiting - Firebase credentials required to proceed")
        sys.exit(1)

# Health check endpoint (for cron monitoring)
@app.get("/health")
def health_check():
    """
    Health check endpoint for monitoring
    Called by cron script every 5 minutes to ensure service is running
    """
    try:
        # Quick DB test
        db = next(get_db_session())
        db.execute(text("SELECT 1 FROM DUAL"))  # Oracle test query
        db.close()
        
        logger.debug("Health check passed")
        return {
            "status": "healthy",
            "timestamp": datetime.now().isoformat(),
            "firebase": "initialized",
            "database": "connected"
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return JSONResponse(
            status_code=503,
            content={
                "status": "unhealthy",
                "error": str(e)
            }
        )

# Include notification routes
app.include_router(notification_router)

# Include patient routes (no auth required)
app.include_router(patient_router)

# Root endpoint
@app.get("/")
def root():
    """Root endpoint - service info"""
    return {
        "service": "Teeth Management Notification Service",
        "version": "1.0.0",
        "environment": "production",
        "endpoints": {
            "health": "/health",
            "notifications": "/api/notifications/*"
        },
        "documentation": "/docs"
    }

# Device token registration endpoint
@app.post("/api/v1/device-tokens/register")
def register_device_token(request: DeviceTokenRequest, db: Session = Depends(get_db_session)):
    """
    Register Firebase device token for a user
    
    IMPORTANT: user_id MUST come from backend login response (NOT auto-generated)
    
    Flow:
    1. Mobile app logs in to Java backend → receives user_id (e.g., 454)
    2. Mobile app calls this endpoint with that user_id
    3. Device token linked to backend's user_id
    4. Java backend sends notifications to same user_id
    5. Notifications delivered to device ✓
    
    This ensures user IDs are IDENTICAL between backend and notification service
    """
    try:
        from models.database_models import PatientDeviceToken
        
        fcm_token = request.fcmToken
        user_id = request.user_id  # MUST come from backend login
        device_type = request.deviceType
        device_model = request.deviceModel
        os_version = request.osVersion
        
        # fcmToken is REQUIRED
        if not fcm_token or not fcm_token.strip():
            raise HTTPException(status_code=400, detail="fcmToken is required")
        
        # user_id REQUIRED - must come from backend login
        if not user_id:
            raise HTTPException(
                status_code=400, 
                detail="user_id is required. Please login to backend first and use the returned user_id"
            )
        
        logger.info(f"Device token registration: user_id={user_id}, device={device_type}")
        
        # Check if token already exists
        existing = db.query(PatientDeviceToken).filter(
            PatientDeviceToken.fcm_token == fcm_token
        ).first()
        
        if existing:
            # Update existing token
            existing.user_id = user_id  # Always update to latest user_id from backend
            existing.is_active = True
            existing.device_type = device_type or existing.device_type
            existing.device_model = device_model or existing.device_model
            existing.os_version = os_version or existing.os_version
            existing.last_used_at = utc_now()
            db.commit()
            logger.info(f"✓ Updated device token for user {user_id}: {fcm_token[:20]}... ({device_type})")
        else:
            # Create new token entry with backend user_id
            token_entry = PatientDeviceToken(
                user_id=user_id,
                fcm_token=fcm_token,
                device_type=device_type,
                device_model=device_model,
                os_version=os_version,
                is_active=True,
                created_at=utc_now()
            )
            db.add(token_entry)
            db.commit()
            logger.info(f"✓ Registered device token for user {user_id}: {fcm_token[:20]}... ({device_type})")
        
        return {
            "success": True,
            "message": "Device token registered successfully - ready to receive notifications",
            "user_id": user_id,
            "device_type": device_type,
            "device_model": device_model,
            "fcm_token": fcm_token[:20] + "..."
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error registering device token: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    
    logger.info("Starting Notification Service on port 9000")
    
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=9000,
        log_level="info",
        workers=1  # Single instance per requirements
    )
