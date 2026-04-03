"""
Main FastAPI Application
Thoutha Notification Service
"""
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from contextlib import asynccontextmanager
import sys
import os

# Add current directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from config import settings
from routes import router
from services import firebase_service
from utils import setup_logger

logger = setup_logger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Handle FastAPI startup and shutdown events"""
    # Startup
    logger.info("=" * 60)
    logger.info("🚀 Starting Thoutha Notification Service")
    logger.info("=" * 60)
    
    try:
        # Initialize Firebase
        firebase_service.initialize_firebase()
        
        # Verify Firebase
        if firebase_service.verify_initialization():
            logger.info("✓ Firebase initialization verified")
        else:
            logger.warning("⚠ Firebase verification returned False")
        
        logger.info(f"✓ Service running on {settings.host}:{settings.port}")
        logger.info("=" * 60)
        
    except Exception as e:
        logger.error(f"✗ Startup failed: {str(e)}")
        logger.error("=" * 60)
        raise
    
    yield
    
    # Shutdown
    logger.info("=" * 60)
    logger.info("🛑 Shutting down Thoutha Notification Service")
    logger.info("=" * 60)

# Initialize FastAPI application
app = FastAPI(
    title="Thoutha Notification Service",
    description="Firebase Cloud Messaging notification service for Thoutha Teeth Management System",
    version="1.0.0",
    lifespan=lifespan
)

# Include notification routes
app.include_router(router)

# Global exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Handle all unhandled exceptions"""
    logger.error(f"✗ Unhandled exception: {str(exc)}")
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "Internal server error",
            "error": str(exc) if settings.debug else "Internal server error"
        }
    )

@app.get("/")
def root():
    """Root endpoint"""
    return {
        "service": "Thoutha Notification Service",
        "version": "1.0.0",
        "status": "running",
        "endpoints": {
            "health": "/api/notify/health",
            "send_notification": "POST /api/notify/send",
            "send_with_retry": "POST /api/notify/send-with-retry",
            "send_multicast": "POST /api/notify/send-multicast",
            "send_to_topic": "POST /api/notify/send-to-topic",
            "statistics": "GET /api/notify/statistics"
        }
    }

if __name__ == "__main__":
    import uvicorn
    
    logger.info("Starting server with uvicorn...")
    uvicorn.run(
        app,
        host=settings.host,
        port=settings.port,
        log_level=settings.log_level.lower()
    )
