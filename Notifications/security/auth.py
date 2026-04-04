"""
Security and authentication module
Provides API Key and JWT validation
"""
import jwt
from fastapi import Depends, HTTPException, Header
from typing import Optional
from config import settings
from utils import setup_logger

logger = setup_logger(__name__)

class SecurityManager:
    """Manages API authentication and authorization"""
    
    @staticmethod
    def validate_api_key(x_api_key: str = Header(...)) -> str:
        """Validate API key from request header.
        
        Args:
            x_api_key: API key from X-API-Key header
            
        Returns:
            API key if valid
            
        Raises:
            HTTPException: If API key is invalid
        """
        if x_api_key != settings.api_key:
            logger.warning(f"✗ Invalid API key attempt: {x_api_key[:10]}...")
            raise HTTPException(
                status_code=401,
                detail="Invalid API key"
            )
        
        logger.info("✓ API key validated successfully")
        return x_api_key
    
    @staticmethod
    def validate_jwt_token(authorization: Optional[str] = Header(None)) -> dict:
        """Validate JWT token from Authorization header.
        
        Args:
            authorization: Authorization header (Bearer <token>)
            
        Returns:
            Decoded JWT payload if valid
            
        Raises:
            HTTPException: If token is invalid or missing
        """
        if not authorization:
            logger.warning("✗ Missing authorization header")
            raise HTTPException(
                status_code=401,
                detail="Missing authorization header"
            )
        
        try:
            scheme, token = authorization.split()
            
            if scheme.lower() != "bearer":
                raise ValueError("Invalid authorization scheme")
            
            # Decode JWT token
            payload = jwt.decode(
                token,
                settings.jwt_secret,
                algorithms=["HS256"]
            )
            
            logger.info("✓ JWT token validated successfully")
            return payload
            
        except ValueError as e:
            logger.warning(f"✗ Invalid authorization format: {str(e)}")
            raise HTTPException(
                status_code=401,
                detail="Invalid authorization format"
            )
        except jwt.ExpiredSignatureError:
            logger.warning("✗ JWT token expired")
            raise HTTPException(
                status_code=401,
                detail="Token has expired"
            )
        except jwt.InvalidTokenError as e:
            logger.warning(f"✗ Invalid JWT token: {str(e)}")
            raise HTTPException(
                status_code=401,
                detail="Invalid token"
            )
    
    @staticmethod
    def create_jwt_token(data: dict, expires_in: int = 3600) -> str:
        """Create a JWT token.
        
        Args:
            data: Data to encode in token
            expires_in: Token expiration time in seconds
            
        Returns:
            Encoded JWT token
        """
        import time
        
        payload = {
            **data,
            "exp": time.time() + expires_in
        }
        
        token = jwt.encode(
            payload,
            settings.jwt_secret,
            algorithm="HS256"
        )
        
        logger.info("✓ JWT token created successfully")
        return token

# Global security manager instance
security_manager = SecurityManager()
