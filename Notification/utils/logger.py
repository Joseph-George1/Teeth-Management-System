"""
Logging configuration for Notification Service
Provides structured logging with file and console output

Location: Notification/utils/logger.py
"""

import logging
import os
from logging.handlers import RotatingFileHandler
from datetime import datetime

# Create logs directory if it doesn't exist
LOG_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "logs")
os.makedirs(LOG_DIR, exist_ok=True)

LOG_FILE = os.path.join(LOG_DIR, "notification.log")
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

# Log format with timestamps
LOG_FORMAT = logging.Formatter(
    '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

def setup_logger(name: str) -> logging.Logger:
    """
    Setup logger with file and console handlers
    
    Args:
        name: Logger name (typically __name__)
    
    Returns:
        Configured logger instance
    """
    logger = logging.getLogger(name)
    logger.setLevel(LOG_LEVEL)
    
    # Avoid duplicate handlers if logger already configured
    if logger.handlers:
        return logger
    
    # Console handler (stdout)
    console_handler = logging.StreamHandler()
    console_handler.setLevel(LOG_LEVEL)
    console_handler.setFormatter(LOG_FORMAT)
    logger.addHandler(console_handler)
    
    # File handler with rotation (max 10MB, keep 5 backups)
    try:
        file_handler = RotatingFileHandler(
            LOG_FILE,
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=5
        )
        file_handler.setLevel(LOG_LEVEL)
        file_handler.setFormatter(LOG_FORMAT)
        logger.addHandler(file_handler)
    except Exception as e:
        print(f"Warning: Could not setup file logging: {e}")
    
    return logger


# Module-level logger
logger = setup_logger(__name__)
