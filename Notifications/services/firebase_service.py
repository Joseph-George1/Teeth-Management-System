"""
Firebase service module
Handles Firebase Admin SDK initialization and verification
"""
import os
import firebase_admin
from firebase_admin import credentials, messaging
from config import settings
from utils import setup_logger

logger = setup_logger(__name__)

class FirebaseService:
    """Service for managing Firebase Admin SDK operations"""
    
    _instance = None
    _initialized = False
    
    def __new__(cls):
        """Implement singleton pattern"""
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        """Initialize Firebase service"""
        if not self._initialized:
            self.initialize_firebase()
            self._initialized = True
    
    @staticmethod
    def initialize_firebase():
        """
        Initialize Firebase Admin SDK
        
        Raises:
            FileNotFoundError: If service account key not found
            Exception: If Firebase initialization fails
        """
        try:
            # Check if Firebase app is already initialized
            try:
                firebase_admin.get_app()
                logger.info("✓ Firebase Admin SDK already initialized")
                return True
            except ValueError:
                # App not initialized yet, proceed with initialization
                pass
            
            service_account_path = settings.firebase_service_account_path
            
            # Check if service account file exists
            if not os.path.exists(service_account_path):
                raise FileNotFoundError(
                    f"Firebase service account key not found at: {service_account_path}\n"
                    "Please download the service account JSON from Firebase Console and place it in the project root."
                )
            
            # Initialize Firebase Admin SDK
            cred = credentials.Certificate(service_account_path)
            firebase_admin.initialize_app(cred)
            
            logger.info("✓ Firebase Admin SDK initialized successfully")
            return True
            
        except FileNotFoundError as e:
            logger.error(f"Service account file error: {str(e)}")
            raise
        except Exception as e:
            logger.error(f"Failed to initialize Firebase: {str(e)}")
            raise
    
    @staticmethod
    def verify_initialization() -> bool:
        """
        Verify Firebase is properly initialized
        
        Returns:
            True if Firebase is initialized, False otherwise
        """
        try:
            # Try to access Firebase messaging client
            _ = messaging.client()
            logger.info("✓ Firebase initialization verified")
            return True
        except Exception as e:
            logger.error(f"Firebase verification failed: {str(e)}")
            return False
    
    @staticmethod
    def get_messaging_client():
        """
        Get Firebase messaging client
        
        Returns:
            Firebase messaging client instance
        """
        return messaging.client()

# Global Firebase service instance
firebase_service = FirebaseService()
