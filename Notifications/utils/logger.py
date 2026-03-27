"""
Logging utility for Notification Service
Provides structured logging for all components
Note: When running under astart, all output is captured to process logs automatically
"""
import logging
import sys
from config import settings

def setup_logger(name: str) -> logging.Logger:
    """Setup and return a logger instance.
    
    Args:
        name: Logger name (typically __name__)
        
    Returns:
        Configured logger instance
        
    Note:
        Output goes to console/stdout. astart automatically captures this.
    """
    logger = logging.getLogger(name)
    
    # Only configure if not already configured
    if not logger.handlers:
        logger.setLevel(settings.log_level)
        
        # Console handler only (astart captures stdout)
        console_handler = logging.StreamHandler(sys.stdout)
        console_handler.setLevel(settings.log_level)
        
        # Formatter with timestamp
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        console_handler.setFormatter(formatter)
        
        logger.addHandler(console_handler)
    
    return logger

# Global logger instance
logger = setup_logger(__name__)
