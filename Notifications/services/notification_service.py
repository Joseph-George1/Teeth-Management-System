"""
Notification service module
Handles sending notifications via Firebase Cloud Messaging
Includes retry mechanism and failure tracking
"""
import time
from typing import List, Dict, Optional
from firebase_admin import messaging
from models import NotificationResponse, MulticastResponse
from utils import setup_logger

logger = setup_logger(__name__)

class NotificationService:
    """Service for sending notifications via Firebase Cloud Messaging"""
    
    MAX_RETRIES = 3
    RETRY_DELAY = 1  # seconds
    
    def __init__(self):
        """Initialize notification service"""
        self.failure_log = []
        self.success_count = 0
        self.failure_count = 0
    
    def send_notification(
        self,
        token: str,
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None
    ) -> NotificationResponse:
        """
        Send a notification to a single device
        
        Args:
            token: Device registration token
            title: Notification title
            body: Notification body
            data: Optional key-value data payload
            
        Returns:
            NotificationResponse with success status and message ID
        """
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                token=token
            )
            
            message_id = messaging.send(message)
            
            logger.info(f"✓ Notification sent successfully. Message ID: {message_id}, Token: {token[:10]}...")
            self.success_count += 1
            
            return NotificationResponse(
                success=True,
                message="Notification sent successfully",
                message_id=message_id
            )
            
        except messaging.InvalidArgumentError as e:
            error_msg = f"Invalid argument: {str(e)}"
            logger.error(f"✗ {error_msg} - Token: {token[:10]}...")
            self.failure_count += 1
            self._log_failure(token, error_msg)
            
            return NotificationResponse(
                success=False,
                message="Invalid request parameters",
                errors=[error_msg]
            )
            
        except messaging.UnregisteredError as e:
            error_msg = f"Unregistered device: {str(e)}"
            logger.error(f"✗ {error_msg} - Token: {token[:10]}...")
            self.failure_count += 1
            self._log_failure(token, error_msg)
            
            return NotificationResponse(
                success=False,
                message="Device is not registered",
                errors=[error_msg]
            )
            
        except Exception as e:
            error_msg = f"Failed to send notification: {str(e)}"
            logger.error(f"✗ {error_msg} - Token: {token[:10]}...")
            self.failure_count += 1
            self._log_failure(token, error_msg)
            
            return NotificationResponse(
                success=False,
                message="Failed to send notification",
                errors=[error_msg]
            )
    
    def send_notification_with_retry(
        self,
        token: str,
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None
    ) -> NotificationResponse:
        """
        Send a notification with retry mechanism
        
        Args:
            token: Device registration token
            title: Notification title
            body: Notification body
            data: Optional key-value data payload
            
        Returns:
            NotificationResponse with success status
        """
        for attempt in range(self.MAX_RETRIES):
            try:
                response = self.send_notification(token, title, body, data)
                if response.success:
                    return response
                
                # If not successful and not last attempt, wait before retrying
                if attempt < self.MAX_RETRIES - 1:
                    logger.warning(f"Retrying notification delivery (attempt {attempt + 2}/{self.MAX_RETRIES})...")
                    time.sleep(self.RETRY_DELAY)
                    
            except Exception as e:
                logger.error(f"Retry attempt {attempt + 1} failed: {str(e)}")
                if attempt == self.MAX_RETRIES - 1:
                    return NotificationResponse(
                        success=False,
                        message="Failed after maximum retry attempts",
                        errors=[str(e)]
                    )
        
        return response
    
    def send_multicast(
        self,
        tokens: List[str],
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None
    ) -> MulticastResponse:
        """
        Send notifications to multiple devices (multicast)
        Handles partial failures gracefully
        
        Args:
            tokens: List of device registration tokens
            title: Notification title
            body: Notification body
            data: Optional key-value data payload
            
        Returns:
            MulticastResponse with success/failure counts and details
        """
        try:
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                tokens=tokens
            )
            
            response = messaging.send_multicast(message)
            
            successful = response.success_count
            failed = response.failure_count
            
            logger.info(
                f"✓ Multicast sent. Success: {successful}/{len(tokens)}, "
                f"Failed: {failed}/{len(tokens)}"
            )
            
            # Log failures
            for idx, error in enumerate(response.errors):
                if error is not None:
                    error_msg = f"Token {idx}: {str(error)}"
                    logger.warning(f"✗ {error_msg}")
                    self.failure_log.append(error_msg)
            
            self.success_count += successful
            self.failure_count += failed
            
            return MulticastResponse(
                success=failed == 0,
                message="Multicast completed",
                successful=successful,
                failed=failed,
                message_ids=response.responses[:successful] if response.responses else [],
                errors=[
                    {
                        "token_index": idx,
                        "error": str(error)
                    }
                    for idx, error in enumerate(response.errors) if error is not None
                ]
            )
            
        except Exception as e:
            error_msg = f"Multicast send failed: {str(e)}"
            logger.error(f"✗ {error_msg}")
            self.failure_count += len(tokens)
            self._log_failure_batch(tokens, error_msg)
            
            return MulticastResponse(
                success=False,
                message="Multicast send failed",
                successful=0,
                failed=len(tokens),
                errors=[{"error": error_msg}]
            )
    
    def send_to_topic(
        self,
        topic: str,
        title: str,
        body: str,
        data: Optional[Dict[str, str]] = None
    ) -> NotificationResponse:
        """
        Send notification to all devices subscribed to a topic
        
        Args:
            topic: Topic name
            title: Notification title
            body: Notification body
            data: Optional key-value data payload
            
        Returns:
            NotificationResponse with message ID
        """
        try:
            message = messaging.Message(
                notification=messaging.Notification(
                    title=title,
                    body=body
                ),
                data=data or {},
                topic=topic
            )
            
            message_id = messaging.send(message)
            
            logger.info(f"✓ Topic notification sent. Topic: {topic}, Message ID: {message_id}")
            self.success_count += 1
            
            return NotificationResponse(
                success=True,
                message="Topic notification sent successfully",
                message_id=message_id
            )
            
        except Exception as e:
            error_msg = f"Failed to send topic notification: {str(e)}"
            logger.error(f"✗ {error_msg}")
            self.failure_count += 1
            self._log_failure(topic, error_msg)
            
            return NotificationResponse(
                success=False,
                message="Failed to send topic notification",
                errors=[error_msg]
            )
    
    def subscribe_to_topic(self, tokens: List[str], topic: str) -> Dict:
        """
        Subscribe devices to a topic
        
        Args:
            tokens: List of device registration tokens
            topic: Topic name
            
        Returns:
            Dict with subscription results
        """
        try:
            response = messaging.make_topic_management_client().make_topic_management_request(
                messaging.TopicManagementRequest(
                    operation="subscribe",
                    tokens=tokens,
                    topic=topic
                )
            )
            
            logger.info(f"✓ Subscribed {len(tokens)} devices to topic: {topic}")
            return {
                "success": True,
                "message": f"Successfully subscribed to topic: {topic}",
                "subscribed_count": len(tokens)
            }
            
        except Exception as e:
            error_msg = f"Failed to subscribe to topic: {str(e)}"
            logger.error(f"✗ {error_msg}")
            return {
                "success": False,
                "message": error_msg,
                "subscribed_count": 0
            }
    
    def unsubscribe_from_topic(self, tokens: List[str], topic: str) -> Dict:
        """
        Unsubscribe devices from a topic
        
        Args:
            tokens: List of device registration tokens
            topic: Topic name
            
        Returns:
            Dict with unsubscription results
        """
        try:
            response = messaging.make_topic_management_client().make_topic_management_request(
                messaging.TopicManagementRequest(
                    operation="unsubscribe",
                    tokens=tokens,
                    topic=topic
                )
            )
            
            logger.info(f"✓ Unsubscribed {len(tokens)} devices from topic: {topic}")
            return {
                "success": True,
                "message": f"Successfully unsubscribed from topic: {topic}",
                "unsubscribed_count": len(tokens)
            }
            
        except Exception as e:
            error_msg = f"Failed to unsubscribe from topic: {str(e)}"
            logger.error(f"✗ {error_msg}")
            return {
                "success": False,
                "message": error_msg,
                "unsubscribed_count": 0
            }
    
    def get_statistics(self) -> Dict:
        """
        Get notification statistics
        
        Returns:
            Dict with success/failure counts and logs
        """
        return {
            "total_success": self.success_count,
            "total_failures": self.failure_count,
            "failure_log": self.failure_log[-100:] if self.failure_log else []  # Last 100 failures
        }
    
    def _log_failure(self, identifier: str, error: str):
        """Log a single failure"""
        self.failure_log.append(f"[{identifier}] {error}")
    
    def _log_failure_batch(self, identifiers: List[str], error: str):
        """Log batch failure"""
        for identifier in identifiers:
            self.failure_log.append(f"[{identifier}] {error}")

# Global notification service instance
notification_service = NotificationService()
