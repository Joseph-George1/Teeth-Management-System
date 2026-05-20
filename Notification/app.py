"""Notification microservice application initialization"""
import logging.config
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from config.logging_config import LOGGING_CONFIG
from routes.notification_routes import router as notification_router

logging.config.dictConfig(LOGGING_CONFIG)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """App startup and shutdown events"""
    # Startup
    logger = logging.getLogger(__name__)
    logger.info("Notification microservice starting...")
    yield
    # Shutdown
    logger.info("Notification microservice shutting down...")

app = FastAPI(
    title="Dental Clinic Notification Service",
    description="Microservice for managing patient and doctor notifications",
    version="1.0.0",
    lifespan=lifespan
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routes
app.include_router(notification_router)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "service": "notification-microservice",
        "status": "running"
    }
