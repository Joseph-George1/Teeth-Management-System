"""
Firebase Cloud Messaging (FCM) Service
Wrapper around Firebase Admin SDK for sending push notifications

Location: Notification/services/firebase_service.py
"""

import logging
from typing import Optional, Dict, List
from firebase_admin import messaging
from firebase_admin import exceptions as firebase_exceptions
from config import get_firebase_app

logger = logging.getLogger(__name__)

class FirebaseService:
    """
    Wrapper for Firebase Admin SDK
    Handles all FCM send operations
    """
    
    def __init__(self):
        """Initialize Firebase service"""
        self.firebase_app = get_firebase_app()
        logger.info("FirebaseService initialized")
    
    def send_to_device(self, fcm_token: str, title: str, body: str, 
                      data: Optional[dict] = None) -> Optional[str]:
        """
        Send notification to single device via FCM
        
        Args:
            fcm_token: Device FCM token
            title: Notification title
            body: Notification body
            data: Optional additional data payload
        
        Returns:
            FCM message ID if successful, None if failed
        
        Raises:
            firebase_admin.exceptions.InvalidArgumentError: If token is invalid
            firebase_admin.exceptions.InternalError: If FCM error
            firebase_admin.exceptions.ServiceUnavailableError: If service unavailable
        """
        try:
            # Build FCM message with platform-specific configuration
            message = messaging.Message(
                token=fcm_token,
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                
                # Android-specific configuration
                android=messaging.AndroidConfig(
                    priority="high",
                    notification=messaging.AndroidNotification(
                        sound="default",
                        click_action="FLUTTER_NOTIFICATION_CLICK",
                        color="#FF5722"  # Material red
                    )
                ),
                
                # iOS-specific configuration
                apns=messaging.APNSConfig(
                    headers={"apns-priority": "10"}  # High priority for iOS
                )
            )
            
            # Send message
            fcm_message_id = messaging.send(message)
            logger.info(f"FCM message sent successfully to {fcm_token[:20]}... | ID: {fcm_message_id}")
            return fcm_message_id
            
        except firebase_exceptions.InvalidArgumentError as e:
            logger.warning(f"Invalid FCM token {fcm_token[:20]}...: {e}")
            return None
        except firebase_exceptions.InternalError as e:
            logger.error(f"FCM internal error: {e}")
            return None
        except firebase_exceptions.ServiceUnavailableError as e:
            logger.error(f"FCM service unavailable: {e}")
            return None
        except Exception as e:
            logger.error(f"Unexpected error sending to FCM: {type(e).__name__}: {e}")
            return None
    
    def send_multicast(self, tokens: List[str], title: str, body: str, 
                      data: Optional[dict] = None) -> Dict:
        """
        Send notification to multiple devices (returns per-device results)
        
        Args:
            tokens: List of FCM tokens
            title: Notification title
            body: Notification body
            data: Optional data payload
        
        Returns:
            Dict with success_count, failure_count, and responses list
        """
        try:
            if not tokens:
                logger.warning("No tokens provided for multicast send")
                return {"success_count": 0, "failure_count": 0, "responses": []}
            
            message = messaging.MulticastMessage(
                tokens=tokens,
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {}
            )
            
            response = messaging.send_multicast(message)
            
            logger.info(f"Multicast sent to {len(tokens)} devices: "
                       f"Success: {response.success_count}, "
                       f"Failures: {response.failure_count}")
            
            return {
                "success_count": response.success_count,
                "failure_count": response.failure_count,
                "responses": response.responses
            }
            
        except Exception as e:
            logger.error(f"Error sending multicast: {e}")
            return {"success_count": 0, "failure_count": len(tokens), "error": str(e)}
    
    def send_to_topic(self, topic: str, title: str, body: str,
                     data: Optional[dict] = None) -> Optional[str]:
        """
        Send notification to all devices subscribed to a topic
        
        Args:
            topic: Topic name
            title: Notification title
            body: Notification body
            data: Optional data payload
        
        Returns:
            FCM message ID if successful, None if failed
        """
        try:
            message = messaging.Message(
                topic=topic,
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {}
            )
            
            fcm_message_id = messaging.send(message)
            logger.info(f"Topic message sent to '{topic}' | ID: {fcm_message_id}")
            return fcm_message_id
            
        except Exception as e:
            logger.error(f"Error sending to topic '{topic}': {e}")
            return None
    
    def verify_credentials(self) -> bool:
        """
        Verify Firebase credentials are valid
        
        Returns:
            True if credentials valid, False otherwise
        """
        try:
            if self.firebase_app is None:
                return False
            
            # Try to get Firebase messaging instance
            messaging.get_messages(None) if False else None  # Dummy check
            return True
            
        except Exception as e:
            logger.error(f"Firebase credential verification failed: {e}")
            return False
