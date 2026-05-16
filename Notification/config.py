"""
Configuration module for Notification Service
Manages database connections, Firebase initialization, application settings

Location: Notification/config.py

Architecture Notes:
  - Uses pathlib.Path to resolve ../.env relative to this file's location
  - Parses JDBC format from .env and builds explicit Oracle Net descriptor with SERVICE_NAME
  - Bypasses oracledb driver's SID/SERVICE_NAME heuristic guessing for modern PDB connections
"""

import os
import json
import logging
import re
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
import firebase_admin
from firebase_admin import credentials

logger = logging.getLogger(__name__)

# =========================================================================
# ENVIRONMENT SETUP - EXPLICIT RELATIVE PATH TO ../.env
# =========================================================================
"""
Load .env from parent directory using pathlib.Path for explicit, cross-platform resolution.
This ensures the script works correctly regardless of the current working directory.

Example: If config.py is at /app/Notification/config.py, we load /app/.env
"""
NOTIFICATION_DIR = Path(__file__).parent  # /path/to/Notification
ENV_FILE = NOTIFICATION_DIR.parent / ".env"  # /path/to/.env

if ENV_FILE.exists():
    load_dotenv(dotenv_path=ENV_FILE)
    logger.info(f"✓ Loaded environment from: {ENV_FILE}")
else:
    logger.warning(f"⚠ .env file not found at {ENV_FILE}. Using environment variables or defaults.")

# =========================================================================
# DATABASE CONFIGURATION - ORACLE WITH PLUGGABLE DATABASE (PDB)
# =========================================================================
"""
Oracle Connection String Architecture:

Modern Oracle 21c Express uses Pluggable Database (PDB) "XEPDB1" with SERVICE_NAME.
The oracledb driver has heuristic parsing that can misinterpret the connection target.

Solution: Explicitly build Oracle Net descriptor with (CONNECT_DATA=(SERVICE_NAME=...))

Format:
  oracle+oracledb://username:password@hostname:port/?service_name=SERVICE_NAME
  
This bypasses driver guessing and explicitly tells Oracle to use SERVICE_NAME lookup
instead of SID lookup, resolving DPY-6003 "SID not registered" errors.
"""

def parse_jdbc_url(jdbc_url: str) -> dict:
    """
    Parse Oracle JDBC URL to extract connection parameters.
    
    Handles format: jdbc:oracle:thin:@hostname:port/SERVICE_NAME
    
    Args:
        jdbc_url: JDBC connection string from environment
        
    Returns:
        Dictionary with 'host', 'port', 'service_name' keys
        
    Raises:
        ValueError: If URL format is invalid
    """
    # Pattern: jdbc:oracle:thin:@hostname:port/SERVICE_NAME
    pattern = r'jdbc:oracle:thin:@([^:]+):(\d+)/(.+)'
    match = re.match(pattern, jdbc_url)
    
    if not match:
        raise ValueError(
            f"Invalid JDBC URL format: {jdbc_url}\n"
            f"Expected: jdbc:oracle:thin:@hostname:port/SERVICE_NAME"
        )
    
    host, port, service_name = match.groups()
    return {
        'host': host.strip(),
        'port': port.strip(),
        'service_name': service_name.strip()
    }


# Extract database credentials from environment
DB_JDBC_URL = os.getenv("DB_URL")
DB_USERNAME = os.getenv("DB_USERNAME")
DB_PASSWORD = os.getenv("DB_PASSWORD")

# Validate required credentials
if not all([DB_JDBC_URL, DB_USERNAME, DB_PASSWORD]):
    missing = []
    if not DB_JDBC_URL:
        missing.append("DB_URL")
    if not DB_USERNAME:
        missing.append("DB_USERNAME")
    if not DB_PASSWORD:
        missing.append("DB_PASSWORD")
    
    raise ValueError(
        f"Missing required environment variables: {', '.join(missing)}\n"
        f"Expected .env file at: {ENV_FILE}"
    )

# Parse JDBC URL to extract host, port, and service name
try:
    jdbc_params = parse_jdbc_url(DB_JDBC_URL)
    DB_HOST = jdbc_params['host']
    DB_PORT = jdbc_params['port']
    DB_SERVICE_NAME = jdbc_params['service_name']
    
    logger.info(f"✓ Parsed JDBC URL:")
    logger.info(f"  Host: {DB_HOST}")
    logger.info(f"  Port: {DB_PORT}")
    logger.info(f"  Service Name (PDB): {DB_SERVICE_NAME}")
    
except ValueError as e:
    logger.error(f"❌ Failed to parse DB_URL: {e}")
    raise

# Build SQLAlchemy connection string with explicit SERVICE_NAME
# Format: oracle+oracledb://username:password@host:port/?service_name=SERVICE_NAME
# This tells oracledb to use SERVICE_NAME (for PDB) instead of SID lookup
DATABASE_URL = (
    f"oracle+oracledb://{DB_USERNAME}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/"
    f"?service_name={DB_SERVICE_NAME}"
)

logger.info(f"✓ Database connection: {DB_HOST}:{DB_PORT}/{DB_SERVICE_NAME} (as SERVICE_NAME)")

# Create SQLAlchemy engine with production-grade connection pooling
# Configuration tuned for AWS EC2 with background worker processes
engine = create_engine(
    DATABASE_URL,
    echo=False,  # Set to True for SQL logging in debug mode
    # Connection pool settings (critical for background workers)
    pool_size=20,         # Persistent connections in pool
    max_overflow=10,      # Additional connections allowed beyond pool_size
    pool_pre_ping=True,   # Validate connection on checkout (stale connection detection)
    pool_recycle=3600,    # Recycle connections after 1 hour (prevents timeouts)
    pool_timeout=30,      # Wait up to 30 seconds for a connection from the pool
)

# Session factory for dependency injection in FastAPI routes
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


def get_db_session():
    """
    Dependency injection for database session in FastAPI routes.
    
    Usage:
        @app.get("/endpoint")
        def route(db = Depends(get_db_session)):
            # db is a SQLAlchemy Session object
            pass
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
    str(NOTIFICATION_DIR / "firebase-key.json")  # Use pathlib consistently
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
    str(NOTIFICATION_DIR / "logs" / "notification.log")
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
