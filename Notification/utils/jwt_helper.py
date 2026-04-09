"""JWT token handling utilities"""
import logging
import json
import base64
from typing import Dict, Optional

logger = logging.getLogger(__name__)

def decode_jwt_payload(token: str) -> Optional[Dict]:
    """
    Decode JWT payload without verification
    (Assumes token comes from trusted Java backend)
    
    JWT format: header.payload.signature
    Payload is base64url encoded JSON
    
    Args:
        token: Full JWT token string (with "Bearer " prefix removed)
    
    Returns:
        Dict of payload claims or None if parsing fails
    """
    try:
        if not token or token.lower().startswith("bearer "):
            token = token.replace("Bearer ", "").replace("bearer ", "").strip()
        
        # Split into parts
        parts = token.split('.')
        if len(parts) != 3:
            logger.error(f"Invalid JWT format: expected 3 parts, got {len(parts)}")
            return None
        
        # Decode payload (add padding if needed for base64)
        payload_b64 = parts[1]
        padding = 4 - (len(payload_b64) % 4)
        if padding != 4:
            payload_b64 += '=' * padding
        
        payload_json = base64.urlsafe_b64decode(payload_b64)
        payload = json.loads(payload_json)
        
        return payload
    except Exception as e:
        logger.error(f"Failed to decode JWT: {e}")
        return None

def get_user_id_from_token(token: str) -> Optional[int]:
    """
    Extract user_id from JWT token
    
    The Java backend token has claims:
    - sub: email (user identifier)
    - firstName, lastName: user name
    
    We'll need to look up the user_id from the database using the email
    
    Args:
        token: JWT token string
    
    Returns:
        user_id or None if not found
    """
    try:
        payload = decode_jwt_payload(token)
        if not payload:
            return None
        
        # Extract email from 'sub' claim
        email = payload.get('sub')
        if not email:
            logger.error("JWT token missing 'sub' claim (email)")
            return None
        
        logger.info(f"Extracted email from JWT: {email}")
        
        # TODO: Query database to get user_id from email
        # For now, return None and let the caller handle it
        return None
    except Exception as e:
        logger.error(f"Error extracting user_id from token: {e}")
        return None
