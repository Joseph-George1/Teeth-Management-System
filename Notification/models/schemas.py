"""
Pydantic models for request/response validation
Handles HTTP payload validation for all notification endpoints

Location: Notification/models/schemas.py
"""

from pydantic import BaseModel, Field
from typing import Optional, Dict, Any, List
from datetime import datetime

# =========================================================================
# REQUEST DTOs (from client/Java backend)
# =========================================================================

class SendNotificationRequest(BaseModel):
    """
    Request to send a notification immediately
    
    Fields:
        user_id: ID of user to notify
        title: Notification title
        body: Notification body
        template_id: Optional - ID of template if using templates
        variables: Optional - variables for template substitution
        notification_type: Type of notification (for analytics)
        language: 'en' (English) or 'ar' (Arabic)
    """
    user_id: int
    title: str
    body: str
    template_id: Optional[str] = None
    variables: Optional[Dict[str, str]] = None
    notification_type: Optional[str] = None
    language: str = "en"
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": 5,
                "title": "New Appointment Request",
                "body": "New patient booking from Ahmed Hassan",
                "notification_type": "APPOINTMENT_CONFIRMED",
                "language": "en"
            }
        }

class QueueNotificationRequest(BaseModel):
    """Request to queue notification for future delivery"""
    user_id: int
    scheduled_time: datetime
    title: str
    body: str
    notification_type: Optional[str] = None

class MarkAsReadRequest(BaseModel):
    """Request to mark notification as read/unread"""
    is_read: bool = True

class DeliveryStatusQuery(BaseModel):
    """Query for notification delivery status"""
    fcm_message_id: str

class AppointmentNotificationRequest(BaseModel):
    """Request to send appointment notifications"""
    idempotency_key: str = Field(..., description="Unique key for idempotency")
    appointment_id: int = Field(..., description="ID of the appointment")
    patient_id: int = Field(..., description="ID of the patient")
    patient_name: str = Field(..., description="Name of the patient")
    doctor_id: int = Field(..., description="ID of the doctor")
    doctor_name: str = Field(..., description="Name of the doctor")
    category: str = Field(..., description="Medical category/specialty")
    location: str = Field(..., description="City or location of the clinic")
    
    class Config:
        json_schema_extra = {
            "example": {
                "idempotency_key": "appt-123-abc",
                "appointment_id": 1001,
                "patient_id": 501,
                "patient_name": "Ahmed Hassan",
                "doctor_id": 201,
                "doctor_name": "Dr. Sarah Ahmed",
                "category": "Orthodontics",
                "location": "Cairo"
            }
        }

class TreatmentPlanNotificationRequest(BaseModel):
    """Request to notify about treatment plan update"""
    patient_id: int = Field(..., description="ID of the patient")
    patient_name: str = Field(..., description="Name of the patient")
    treatment_plan_id: int = Field(..., description="ID of the treatment plan")
    
    class Config:
        json_schema_extra = {
            "example": {
                "patient_id": 501,
                "patient_name": "Ahmed Hassan",
                "treatment_plan_id": 3001
            }
        }

class PaymentNotificationRequest(BaseModel):
    """Request to notify about payment receipt"""
    patient_id: int = Field(..., description="ID of the patient")
    patient_name: str = Field(..., description="Name of the patient")
    amount: str = Field(..., description="Payment amount")
    currency: str = Field(default="SAR", description="Currency code")
    
    class Config:
        json_schema_extra = {
            "example": {
                "patient_id": 501,
                "patient_name": "Ahmed Hassan",
                "amount": "500",
                "currency": "SAR"
            }
        }

class WebhookPayload(BaseModel):
    """Firebase Cloud Messaging webhook payload"""
    fcm_message_id: str = Field(..., description="FCM message ID")
    status: str = Field(..., description="Delivery status (DELIVERED, BOUNCED, etc)")
    error: Optional[str] = Field(None, description="Error message if failed")
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
    class Config:
        json_schema_extra = {
            "example": {
                "fcm_message_id": "0:1234567890123",
                "status": "DELIVERED",
                "error": None,
                "timestamp": "2026-04-04T10:30:45"
            }
        }

class DeviceTokenRequest(BaseModel):
    """Request to register a device token for FCM
    
    Mobile app can provide user_id OR let backend generate one:
    
    Path 1: With backend user_id (preferred)
    - Mobile logs in → gets user_id=454 from backend
    - Mobile registers device token with user_id=454
    - Notifications sent to user_id=454 work perfectly
    
    Path 2: Without user_id (auto-generate)
    - Mobile registers device token without user_id
    - Notification service generates unique user_id
    - Returns generated user_id to mobile
    - Mobile saves locally and uses for future calls
    
    Both paths result in synchronized user IDs between backend and notification service
    """
    user_id: Optional[int] = Field(None, description="User ID from backend login (optional, auto-generated if missing)")
    fcmToken: str = Field(..., description="Firebase Cloud Messaging device token")
    deviceType: str = Field(default="ANDROID", description="Device type (ANDROID, iOS, WEB)")
    deviceModel: Optional[str] = Field(default="Unknown", description="Device model name")
    osVersion: Optional[str] = Field(default="Unknown", description="OS version")
    
    class Config:
        json_schema_extra = {
            "example": {
                "user_id": 454,
                "fcmToken": "d-o1a3WbSauKMigqcovr4b:APA91bGLfNkOZMrKJXnkkTv5eI_pb39xHsT8jLyNOoJVC2jmavWkgWylFBkUD5LS4cv",
                "deviceType": "ANDROID",
                "deviceModel": "Samsung Galaxy S21",
                "osVersion": "33"
            }
        }

# =========================================================================
# RESPONSE DTOs (to client/Java backend)
# =========================================================================

class SendNotificationResponse(BaseModel):
    """Response from sending notification"""
    message: str
    fcm_message_id: Optional[str] = None
    delivery_status: str  # "PENDING", "SENT", "FAILED", "DELIVERED"
    cached: bool = False  # True if duplicate request (idempotency)
    
    class Config:
        json_schema_extra = {
            "example": {
                "message": "Notification queued",
                "fcm_message_id": None,
                "delivery_status": "PENDING",
                "cached": False
            }
        }

class NotificationStatusResponse(BaseModel):
    """Response with notification status information"""
    fcm_message_id: str
    status: str  # "PENDING", "SENT", "DELIVERED", "FAILED"
    queue_id: Optional[int] = None
    created_at: datetime
    last_retry_at: Optional[datetime] = None
    retry_count: int = 0
    error_message: Optional[str] = None
    
    class Config:
        json_schema_extra = {
            "example": {
                "fcm_message_id": "0:1234567890123",
                "status": "SENT",
                "queue_id": 5001,
                "created_at": "2026-04-04T10:30:45",
                "last_retry_at": None,
                "retry_count": 0,
                "error_message": None
            }
        }

class DeliveryStatusResponse(BaseModel):
    """Response with delivery tracking information"""
    fcm_message_id: str
    status: str  # "SENT", "DELIVERED", "BOUNCED", "FAILED"
    sent_at: datetime
    delivered_at: Optional[datetime] = None
    error_message: Optional[str] = None
    retries: int = 0
    
    class Config:
        json_schema_extra = {
            "example": {
                "fcm_message_id": "a5d2e8f1...",
                "status": "SENT",
                "sent_at": "2026-04-04T08:30:45.890",
                "delivered_at": None,
                "retries": 0
            }
        }

class QueueResponse(BaseModel):
    """Response from queue operation"""
    message: str
    queue_id: int
    status: str
    
    class Config:
        json_schema_extra = {
            "example": {
                "message": "Notification queued",
                "queue_id": 7001,
                "status": "PENDING"
            }
        }

class UnreadNotification(BaseModel):
    """Unread notification for user"""
    id: int
    title: str
    body: str
    notification_type: str
    created_at: datetime
    
    class Config:
        json_schema_extra = {
            "example": {
                "id": 501,
                "title": "New Appointment Request",
                "body": "From Ahmed Hassan",
                "notification_type": "APPOINTMENT_CONFIRMED",
                "created_at": "2026-04-04T08:30:00"
            }
        }

class HealthCheckResponse(BaseModel):
    """Health check response"""
    status: str  # "healthy" or "unhealthy"
    timestamp: datetime
    firebase: str  # "initialized" or error message
    database: str  # "connected" or error message
    
    class Config:
        json_schema_extra = {
            "example": {
                "status": "healthy",
                "timestamp": "2026-04-04T08:35:00",
                "firebase": "initialized",
                "database": "connected"
            }
        }

class ErrorResponse(BaseModel):
    """Error response"""
    error: str
    detail: str
    status_code: int
    
    class Config:
        json_schema_extra = {
            "example": {
                "error": "Validation Error",
                "detail": "user_id is required",
                "status_code": 400
            }
        }
