"""Idempotency utilities for exactly-once delivery"""
import hashlib
import logging
from typing import Optional
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

def generate_idempotency_key(data: str) -> str:
    """Generate idempotency key from data"""
    return hashlib.sha256(data.encode()).hexdigest()

def validate_idempotency(key: str) -> bool:
    """
    Validate idempotency key format
    Idempotency keys should be SHA256 hashes (64 hex characters)
    """
    if not key:
        return False
    
    if not (len(key) == 64 and all(c in '0123456789abcdef' for c in key)):
        # Also allow UUIDs and custom formats
        return len(key) > 0 and len(key) < 256
    
    return True

def is_idempotency_expired(created_at: datetime, ttl_hours: int = 24) -> bool:
    """Check if idempotency key has expired"""
    return datetime.now(timezone.utc) - created_at > timedelta(hours=ttl_hours)
