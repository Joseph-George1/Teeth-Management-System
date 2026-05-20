"""
Teeth Management Notification Service
FastAPI microservice for Firebase Cloud Messaging (FCM) notifications
with support for templates, multi-language, idempotency, and delivery tracking

Location: Notification/main.py
Port: 9000
Created: April 4, 2026
"""

from contextlib import asynccontextmanager
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

# =========================================================================
# LIFESPAN CONTEXT MANAGER - Modern FastAPI Startup/Shutdown Handler
# =========================================================================
"""
FastAPI 0.93+ uses lifespan context managers instead of @app.on_event().
This approach is more explicit and handles both startup and shutdown cleanly.

Replaces deprecated:
  @app.on_event("startup")
  async def startup_event(): ...
"""

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    FastAPI lifespan context manager for startup and shutdown events.
    
    Startup (yield before): Initialize Firebase and background tasks
    Shutdown (after yield): Clean up scheduler gracefully
    """
    # ======================= STARTUP =======================
    try:
        # Try to initialize Firebase
        try:
            init_firebase()
            logger.info("✓ Firebase initialized successfully on startup")
            firebase_enabled = True
        except FileNotFoundError as e:
            logger.warning(f"⚠ Firebase initialization skipped: {e}")
            logger.warning("⚠ Push notifications will not work, but API endpoints will be available for testing")
            firebase_enabled = False
        
        # Import queue service for background notification processing
        from services.queue_service import QueueService
        from services.patient_token_service import PatientTokenService
        
        def process_notifications():
            """Background task to process notification queue (runs every 2 seconds)"""
            try:
                if not firebase_enabled:
                    return  # Skip if Firebase not initialized
                db = next(get_db_session())
                queue_service = QueueService(db)
                queue_service.process_queue(db)
                db.close()
            except Exception as e:
                logger.error(f"Background queue processor error: {e}")
        
        def cleanup_patient_tokens():
            """Background task to cleanup expired patient tokens (runs every hour)"""
            try:
                db = next(get_db_session())
                token_service = PatientTokenService(db)
                deleted = token_service.cleanup_expired_tokens()
                db.close()
            except Exception as e:
                logger.error(f"Patient token cleanup error: {e}")
        
        # Initialize APScheduler for background tasks
        scheduler = BackgroundScheduler()
        scheduler.add_job(process_notifications, 'interval', seconds=2)
        scheduler.add_job(cleanup_patient_tokens, 'interval', hours=1)
        scheduler.start()
        
        logger.info("✓ Background notification queue processor started (runs every 2 seconds)")
        logger.info("✓ Patient token cleanup started (runs every hour)")
        logger.info(f"✓ Notification Service ready on port 9000 (Firebase: {'enabled' if firebase_enabled else 'disabled'})")
        
        # Store scheduler in app state for access in shutdown
        app.state.scheduler = scheduler
        
        yield  # Application runs here
        
    except Exception as e:
        logger.error(f"Failed to initialize service: {e}")
        sys.exit(1)
    
    # ======================= SHUTDOWN =======================
    finally:
        # Clean up scheduler gracefully
        if hasattr(app.state, 'scheduler'):
            app.state.scheduler.shutdown()
            logger.info("Background scheduler shut down gracefully")

# Create FastAPI app with lifespan handler
app = FastAPI(
    title="Teeth Management Notification Service",
    version="1.0.0",
    description="Advanced notification service with FCM, templates, multi-language, and delivery tracking",
    lifespan=lifespan  # Modern way to handle startup/shutdown
)

# Enable CORS (for Java backend calling from different port)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

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
    Register Firebase device token - syncs with backend user IDs
    
    CRITICAL: The mobile app sends the Doctor/Patient ID as 'user_id' in the
    request body. This endpoint MUST trust and use that ID for token storage,
    because all downstream notification lookups (queue_service.py) query by
    this same ID.
    
    FIX HISTORY: Previously, the Pydantic schema only defined 'patient_id'
    but the mobile app sent 'user_id'. Pydantic silently dropped the unknown
    field, causing tokens to be saved without a valid ID → notification failures.
    """
    try:
        from models.database_models import PatientDeviceToken
        
        fcm_token = request.fcmToken
        # CRITICAL FIX: Use get_resolved_user_id() which accepts BOTH
        # 'user_id' (sent by mobile app) and 'patient_id' (legacy field name)
        resolved_id = request.get_resolved_user_id()
        device_type = request.deviceType
        device_model = request.deviceModel
        os_version = request.osVersion
        
        # fcmToken is REQUIRED
        if not fcm_token or not fcm_token.strip():
            raise HTTPException(status_code=400, detail="fcmToken is required")
        
        logger.info(f"Device token registration: resolved_id={resolved_id} "
                     f"(user_id={request.user_id}, patient_id={request.patient_id}), "
                     f"device={device_type}")
        
        # Check if token already exists
        existing = db.query(PatientDeviceToken).filter(
            PatientDeviceToken.fcm_token == fcm_token
        ).first()
        
        if existing:
            # Update existing token — ALWAYS update the ID if provided
            if resolved_id is not None:
                existing.user_id = resolved_id      # For queue_service fallback lookup
                existing.patient_id = resolved_id    # For queue_service primary lookup
            existing.is_active = True
            existing.device_type = device_type or existing.device_type
            existing.device_model = device_model or existing.device_model
            existing.os_version = os_version or existing.os_version
            existing.last_used_at = utc_now()
            db.commit()
            logger.info(f"✓ Updated device token: user_id={existing.user_id}, "
                        f"patient_id={existing.patient_id}: {fcm_token[:20]}... ({device_type})")
            assigned_user_id = existing.user_id
        else:
            # For new registrations: use the resolved ID, or auto-generate one
            user_id = resolved_id
            if user_id is None:
                try:
                    result = db.execute(text("SELECT seq_user_id.NEXTVAL as next_id FROM dual"))
                    user_id = result.scalar()
                    logger.info(f"Generated new user_id from sequence: {user_id}")
                except Exception as seq_error:
                    try:
                        result = db.execute(text(
                            "SELECT NVL(MAX(user_id), 999) + 1 as next_id FROM PATIENT_DEVICE_TOKENS"
                        ))
                        user_id = result.scalar()
                        if user_id is None:
                            user_id = 1000
                        logger.info(f"Generated new user_id (fallback from max): {user_id}")
                    except Exception as max_error:
                        logger.warning(f"Could not query max user_id: {max_error}, using timestamp-based ID")
                        import time
                        user_id = int(time.time() * 1000) % 9999999
                        logger.info(f"Generated new user_id (timestamp-based): {user_id}")
            
            # Create new token entry — store resolved ID in BOTH columns
            # so queue_service can find it whether it queries by patient_id or user_id
            token_entry = PatientDeviceToken(
                user_id=user_id,
                patient_id=user_id,   # CRITICAL: Set patient_id = user_id for consistency
                fcm_token=fcm_token,
                device_type=device_type,
                device_model=device_model,
                os_version=os_version,
                is_active=True,
                created_at=utc_now()
            )
            db.add(token_entry)
            db.commit()
            logger.info(f"✓ Registered device token: user_id={user_id}, "
                        f"patient_id={user_id}: {fcm_token[:20]}... ({device_type})")
            assigned_user_id = user_id
        
        return {
            "success": True,
            "message": "Device token registered successfully",
            "user_id": assigned_user_id,
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
