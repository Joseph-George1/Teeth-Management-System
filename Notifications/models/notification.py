"""
Data models for Notification Service
"""
from pydantic import BaseModel
from typing import Optional, Dict, List

class NotificationRequest(BaseModel):
    """Model for single notification request"""
    token: str
    title: str
    body: str
    data: Optional[Dict[str, str]] = None


class MulticastNotificationRequest(BaseModel):
    """Model for multicast notification request"""
    tokens: List[str]
    title: str
    body: str
    data: Optional[Dict[str, str]] = None


class TopicNotificationRequest(BaseModel):
    """Model for topic-based notification request"""
    topic: str
    title: str
    body: str
    data: Optional[Dict[str, str]] = None


class NotificationResponse(BaseModel):
    """Model for notification response"""
    success: bool
    message: str
    message_id: Optional[str] = None
    errors: Optional[List[str]] = None


class MulticastResponse(BaseModel):
    """Model for multicast notification response"""
    success: bool
    message: str
    successful: int = 0
    failed: int = 0
    message_ids: List[str] = []
    errors: List[Dict] = []
