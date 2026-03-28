"""
Configuration module for Notification Service
Loads environment variables and provides configuration
"""
import os
from pathlib import Path
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    """Application settings loaded from environment variables"""
    
    # Firebase Configuration
    firebase_service_account_path: str = os.getenv(
        "FIREBASE_SERVICE_ACCOUNT_PATH",
        "./serviceAccountKey.json"
    )
    
    # API Security
    api_key: str = os.getenv("API_KEY", "thoutha-notification-service-key-2024")
    jwt_secret: str = os.getenv("JWT_SECRET", "thoutha-jwt-secret-notification-service")
    
    # Server Configuration
    host: str = os.getenv("HOST", "localhost")
    port: int = int(os.getenv("PORT", 9000))
    debug: bool = os.getenv("DEBUG", "True").lower() == "true"
    
    # Logging
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    
    class Config:
        env_file = ".env"
        case_sensitive = False

# Global settings instance
settings = Settings()
