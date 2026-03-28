"""
Routes for notification endpoints
Handles all API requests for sending notifications
"""
from fastapi import APIRouter, Depends, HTTPException
from models import (
    NotificationRequest,
    MulticastNotificationRequest,
    TopicNotificationRequest,
    NotificationResponse,
    MulticastResponse
)
from services import notification_service
from security import security_manager
from utils import setup_logger

logger = setup_logger(__name__)

# Create router
router = APIRouter(prefix="/api/notify", tags=["notifications"])

@router.post("/send", response_model=NotificationResponse)
def send_notification(
    request: NotificationRequest,
    api_key: str = Depends(security_manager.validate_api_key)
) -> NotificationResponse:
    """
    Send a notification to a single device
    
    Args:
        request: NotificationRequest with token, title, body, data
        api_key: Valid API key from header
        
    Returns:
        NotificationResponse with success status and message ID
    """
    logger.info(f"📨 Received notification request for token: {request.token[:10]}...")
    
    return notification_service.send_notification(
        token=request.token,
        title=request.title,
        body=request.body,
        data=request.data
    )

@router.post("/send-with-retry", response_model=NotificationResponse)
def send_notification_with_retry(
    request: NotificationRequest,
    api_key: str = Depends(security_manager.validate_api_key)
) -> NotificationResponse:
    """
    Send a notification with retry mechanism
    
    Args:
        request: NotificationRequest with token, title, body, data
        api_key: Valid API key from header
        
    Returns:
        NotificationResponse with success status and message ID
    """
    logger.info(f"📨 Received retry notification request for token: {request.token[:10]}...")
    
    return notification_service.send_notification_with_retry(
        token=request.token,
        title=request.title,
        body=request.body,
        data=request.data
    )

@router.post("/send-multicast", response_model=MulticastResponse)
def send_multicast(
    request: MulticastNotificationRequest,
    api_key: str = Depends(security_manager.validate_api_key)
) -> MulticastResponse:
    """
    Send notifications to multiple devices
    
    Args:
        request: MulticastNotificationRequest with tokens, title, body, data
        api_key: Valid API key from header
        
    Returns:
        MulticastResponse with success/failure counts
    """
    logger.info(f"📨 Received multicast request for {len(request.tokens)} devices")
    
    return notification_service.send_multicast(
        tokens=request.tokens,
        title=request.title,
        body=request.body,
        data=request.data
    )

@router.post("/send-to-topic", response_model=NotificationResponse)
def send_to_topic(
    request: TopicNotificationRequest,
    api_key: str = Depends(security_manager.validate_api_key)
) -> NotificationResponse:
    """
    Send a notification to all devices subscribed to a topic
    
    Args:
        request: TopicNotificationRequest with topic, title, body, data
        api_key: Valid API key from header
        
    Returns:
        NotificationResponse with success status and message ID
    """
    logger.info(f"📨 Received topic notification request for topic: {request.topic}")
    
    return notification_service.send_to_topic(
        topic=request.topic,
        title=request.title,
        body=request.body,
        data=request.data
    )

@router.post("/subscribe-topic")
def subscribe_to_topic(
    tokens: list[str],
    topic: str,
    api_key: str = Depends(security_manager.validate_api_key)
):
    """
    Subscribe devices to a topic
    
    Args:
        tokens: List of device tokens
        topic: Topic name
        api_key: Valid API key from header
        
    Returns:
        Success/failure information
    """
    logger.info(f"📨 Received subscription request for topic: {topic}")
    
    return notification_service.subscribe_to_topic(
        tokens=tokens,
        topic=topic
    )

@router.post("/unsubscribe-topic")
def unsubscribe_from_topic(
    tokens: list[str],
    topic: str,
    api_key: str = Depends(security_manager.validate_api_key)
):
    """
    Unsubscribe devices from a topic
    
    Args:
        tokens: List of device tokens
        topic: Topic name
        api_key: Valid API key from header
        
    Returns:
        Success/failure information
    """
    logger.info(f"📨 Received unsubscription request for topic: {topic}")
    
    return notification_service.unsubscribe_from_topic(
        tokens=tokens,
        topic=topic
    )

@router.get("/statistics")
def get_statistics(
    api_key: str = Depends(security_manager.validate_api_key)
):
    """
    Get notification service statistics
    
    Args:
        api_key: Valid API key from header
        
    Returns:
        Service statistics including success/failure counts
    """
    logger.info("📊 Retrieving notification statistics")
    
    return notification_service.get_statistics()

@router.get("/health")
def health_check():
    """
    Health check endpoint
    
    Returns:
        Service status
    """
    return {
        "status": "healthy",
        "service": "Thoutha Notification Service",
        "version": "1.0.0"
    }
