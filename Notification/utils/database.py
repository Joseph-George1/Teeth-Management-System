"""Database utilities"""
import logging
from sqlalchemy import text
from config import SessionLocal

logger = logging.getLogger(__name__)

def get_db():
    """Dependency for getting database session in FastAPI"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def health_check_db() -> bool:
    """Quick database health check"""
    try:
        db = SessionLocal()
        db.execute(text("SELECT 1 FROM DUAL"))  # Oracle test query
        db.close()
        return True
    except Exception as e:
        logger.error(f"Database health check failed: {e}")
        return False
