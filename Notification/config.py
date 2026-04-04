"""
Configuration module for Notification Service
Manages database connections, Firebase initialization, application settings

Location: Notification/config.py
"""

import os
import json
import logging
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import firebase_admin
from firebase_admin import credentials

logger = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()

# =========================================================================
# DATABASE CONFIGURATION
# =========================================================================
# Oracle Database connection settings
DB_USER = os.getenv("DB_USER", "hr")
DB_PASSWORD = os.getenv("DB_PASSWORD", "hr")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "1521")
DB_NAME = os.getenv("DB_NAME", "orclpdb")

# Build Oracle connection string using oracledb driver
DATABASE_URL = f"oracle+oracledb://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"

logger.info(f"Database connection: {DB_HOST}:{DB_PORT}/{DB_NAME}")

# Create SQLAlchemy engine with connection pooling
# pool_size: Number of connections to maintain in pool
# max_overflow: Additional connections allowed beyond pool_size
# pool_pre_ping: Test connection on checkout for stale connection detection
engine = create_engine(
    DATABASE_URL,
    echo=False,  # Set to True for SQL logging in debug
    pool_size=20,         # Connection pool size
    max_overflow=10,      # Additional connections beyond pool size
    pool_pre_ping=True,   # Test connection on checkout
    pool_recycle=3600     # Recycle connections after 1 hour
)

# Session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db_session():
    """
    Dependency injection for database session
    Usage: db = Depends(get_db_session)
    """
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# =========================================================================
# FIREBASE CONFIGURATION
# =========================================================================
# Path to Firebase service account credentials
FIREBASE_KEY_PATH = os.getenv(
    "FIREBASE_KEY_PATH",
    os.path.join(os.path.dirname(__file__), "firebase-key.json")
)

# Global Firebase app instance
_firebase_app = None

def init_firebase():
    """
    Initialize Firebase Admin SDK on application startup
    
    This function:
    1. Checks if firebase-key.json exists
    2. Loads service account credentials
    3. Initializes Firebase Admin SDK
    4. Sets up for FCM messaging
    
    Raises:
        FileNotFoundError: If firebase-key.json not found
        ValueError: If credentials are invalid
    """
    global _firebase_app
    
    if _firebase_app is not None:
        logger.info("Firebase already initialized")
        return _firebase_app
    
    try:
        if not os.path.exists(FIREBASE_KEY_PATH):
            raise FileNotFoundError(
                f"Firebase credentials not found at {FIREBASE_KEY_PATH}\n"
                f"Please provide firebase-key.json in the Notification/ folder\n"
                f"(obtained from Firebase Console → Project Settings → Service Accounts)"
            )
        
        # Load and initialize Firebase
        creds = credentials.Certificate(FIREBASE_KEY_PATH)
        _firebase_app = firebase_admin.initialize_app(creds)
        
        logger.info(f"✓ Firebase Admin SDK initialized successfully")
        logger.info(f"  Credentials: {FIREBASE_KEY_PATH}")
        
        return _firebase_app
        
    except FileNotFoundError as e:
        logger.error(f"❌ {e}")
        raise
    except Exception as e:
        logger.error(f"❌ Failed to initialize Firebase: {e}")
        raise

def get_firebase_app():
    """Get initialized Firebase app instance"""
    if _firebase_app is None:
        init_firebase()
    return _firebase_app

# =========================================================================
# NOTIFICATION SERVICE CONFIGURATION
# =========================================================================
NOTIFICATION_CONFIG = {
    # Retry configuration
    "max_retries": int(os.getenv("MAX_RETRIES", "3")),
    "retry_backoff_multiplier": float(os.getenv("RETRY_BACKOFF_MULTIPLIER", "2.0")),
    "initial_retry_delay_ms": int(os.getenv("INITIAL_RETRY_DELAY_MS", "1000")),
    
    # Queue processing
    "queue_check_interval_seconds": int(os.getenv("QUEUE_CHECK_INTERVAL", "30")),
    
    # Caching
    "template_cache_ttl_seconds": int(os.getenv("TEMPLATE_CACHE_TTL", "300")),
    
    # FCM limits
    "max_devices_per_user": int(os.getenv("MAX_DEVICES_PER_USER", "5")),
}

# =========================================================================
# LOGGING CONFIGURATION
# =========================================================================
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
LOG_FILE = os.getenv(
    "LOG_FILE",
    os.path.join(os.path.dirname(__file__), "logs/notification.log")
)

logger.info(f"Logging level: {LOG_LEVEL}")
logger.info(f"Log file: {LOG_FILE}")

# =========================================================================
# APPLICATION INFO
# =========================================================================
APP_NAME = "Teeth Management Notification Service"
APP_VERSION = "1.0.0"
APP_ENVIRONMENT = os.getenv("ENVIRONMENT", "production")

logger.info(f"Application: {APP_NAME} v{APP_VERSION}")
logger.info(f"Environment: {APP_ENVIRONMENT}")

# =========================================================================
# EMAIL CONFIGURATION
# =========================================================================
class EmailConfig:
    """Email service configuration"""
    
    def __init__(self):
        """Initialize email configuration from environment variables"""
        # SMTP settings
        self.SMTP_SERVER = os.getenv("SMTP_SERVER", "smtp.gmail.com")
        self.SMTP_PORT = int(os.getenv("SMTP_PORT", "587"))
        self.SENDER_EMAIL = os.getenv("SENDER_EMAIL", "noreply@dentalsystem.com")
        self.SENDER_PASSWORD = os.getenv("SENDER_PASSWORD", "")
        
        # Email sending settings
        self.ENABLE_EMAIL = os.getenv("ENABLE_EMAIL", "false").lower() == "true"
        self.USE_TLS = os.getenv("SMTP_USE_TLS", "true").lower() == "true"
        self.USE_SSL = os.getenv("SMTP_USE_SSL", "false").lower() == "true"
        
        # Logging
        if self.ENABLE_EMAIL and not self.SENDER_PASSWORD:
            logger.warning("Email enabled but SENDER_PASSWORD not set in environment variables")
