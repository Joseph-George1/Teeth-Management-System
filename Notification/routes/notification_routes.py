"""API routes for notification microservice"""
import logging
import json
from typing import Optional
from datetime import datetime
from fastapi import APIRouter, HTTPException, Depends, Header
from sqlalchemy.orm import Session
from models.schemas import (
    AppointmentNotificationRequest,
    TreatmentPlanNotificationRequest,
    PaymentNotificationRequest,
    NotificationStatusResponse,
    WebhookPayload
)
from services.notification_service import NotificationService
from services.firebase_service import FirebaseService
from utils.database import get_db
from utils.idempotency import validate_idempotency
from utils.jwt_helper import decode_jwt_payload

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/notifications", tags=["notifications"])

@router.post("/appointment-confirmed")
async def notify_appointment_confirmed(
    request: AppointmentNotificationRequest,
    db: Session = Depends(get_db)
):
    """Queue appointment confirmation notification"""
    try:
        validate_idempotency(request.idempotency_key)
        
        notification_service = NotificationService(db)
        result = notification_service.notify_appointment_confirmed(
            appointment_id=request.appointment_id,
            patient_id=request.patient_id,
            patient_name=request.patient_name,
            doctor_id=request.doctor_id,
            doctor_name=request.doctor_name,
            category=request.category,
            location=request.location
        )
        
        return {
            "success": True,
            "message": "Appointment notifications queued",
            "status": result
        }
    except Exception as e:
        logger.error(f"Error in appointment notification endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/treatment-plan-update")
async def notify_treatment_plan_update(
    request: TreatmentPlanNotificationRequest,
    db: Session = Depends(get_db)
):
    """Notify patient about treatment plan update"""
    try:
        notification_service = NotificationService(db)
        status = notification_service.notify_treatment_plan_update(
            patient_id=request.patient_id,
            patient_name=request.patient_name,
            treatment_plan_id=request.treatment_plan_id
        )
        
        return {
            "success": True,
            "message": "Treatment plan notification queued",
            "status": status
        }
    except Exception as e:
        logger.error(f"Error in treatment plan notification: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/payment-received")
async def notify_payment_received(
    request: PaymentNotificationRequest,
    db: Session = Depends(get_db)
):
    """Notify patient about payment receipt"""
    try:
        notification_service = NotificationService(db)
        status = notification_service.notify_payment_received(
            patient_id=request.patient_id,
            patient_name=request.patient_name,
            amount=request.amount,
            currency=request.currency
        )
        
        return {
            "success": True,
            "message": "Payment notification queued",
            "status": status
        }
    except Exception as e:
        logger.error(f"Error in payment notification: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/status/{fcm_message_id}")
async def get_notification_status(
    fcm_message_id: str,
    db: Session = Depends(get_db)
):
    """Get notification delivery status"""
    try:
        queue_service = NotificationService(db).queue_service
        status = queue_service.get_delivery_status(fcm_message_id)
        
        if not status:
            raise HTTPException(status_code=404, detail="Notification not found")
        
        return status
    except Exception as e:
        logger.error(f"Error getting notification status: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/firebase-webhook")
async def handle_firebase_webhook(
    payload: WebhookPayload,
    db: Session = Depends(get_db)
):
    """Handle Firebase delivery status webhook"""
    try:
        firebase_service = FirebaseService()
        firebase_service.record_delivery_status(payload)
        
        return {"success": True, "message": "Webhook processed"}
    except Exception as e:
        logger.error(f"Error processing firebase webhook: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("")
async def get_notifications(
    limit: int = 50,
    offset: int = 0,
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    """Fetch notifications for authenticated doctor (from JWT token) - returns Flutter NotificationLogModel format"""
    try:
        from models.database_models import NotificationQueue
        
        # Extract token from Authorization header
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        
        # Decode JWT to get email
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Get email from JWT 'sub' claim
        email = payload.get('sub')
        if not email:
            raise HTTPException(status_code=401, detail="Email not found in token")
        
        logger.info(f"Fetching notifications for doctor: {email}")
        
        # Query notifications, ordered by most recent first
        # TODO: Filter by doctor_id when NotificationQueue has doctor_id column
        query = db.query(NotificationQueue).order_by(
            NotificationQueue.created_at.desc()
        )
        
        total_count = query.count()
        notifications = query.limit(limit).offset(offset).all()
        
        # Format response to match Flutter NotificationLogModel structure
        data = []
        for notif in notifications:
            payload_obj = json.loads(notif.payload) if notif.payload else {}
            
            # Extract fields from payload
            notification_item = {
                "id": notif.id,
                "title": payload_obj.get("title", "Notification"),
                "body": payload_obj.get("body", ""),
                "readStatus": notif.status == "DELIVERED",  # Mark as read if delivered
                "createdAt": notif.created_at.isoformat() if notif.created_at else None,
                "appointmentId": payload_obj.get("appointmentId"),
                "messageId": notif.fcm_message_id,
                "doctorId": payload_obj.get("doctorId"),
                "type": payload_obj.get("type", "appointment"),
                "time": payload_obj.get("time"),
                "clinic": payload_obj.get("location"),  # Map location to clinic
                "doctorName": payload_obj.get("doctor_name")
            }
            data.append(notification_item)
        
        return {
            "success": True,
            "data": data
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching notifications: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{notification_id}/read")
async def mark_notification_as_read(
    notification_id: int,
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    """Mark a single notification as read"""
    try:
        from models.database_models import NotificationQueue
        
        # Verify token
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Find and update notification
        notif = db.query(NotificationQueue).filter(
            NotificationQueue.id == notification_id
        ).first()
        
        if not notif:
            raise HTTPException(status_code=404, detail="Notification not found")
        
        notif.status = "DELIVERED"
        notif.updated_at = datetime.utcnow()
        db.commit()
        
        logger.info(f"Marked notification {notification_id} as read")
        
        return {
            "success": True,
            "message": "Notification marked as read"
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error marking notification as read: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/read-all")
async def mark_all_notifications_as_read(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    """Mark all notifications as read"""
    try:
        from models.database_models import NotificationQueue
        
        # Verify token
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Update all PENDING notifications to DELIVERED
        updated_count = db.query(NotificationQueue).filter(
            NotificationQueue.status == "PENDING"
        ).update({"status": "DELIVERED", "updated_at": datetime.utcnow()})
        
        db.commit()
        
        logger.info(f"Marked {updated_count} notifications as read")
        
        return {
            "success": True,
            "message": f"Marked {updated_count} notifications as read"
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error marking all notifications as read: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("/{notification_id}")
async def delete_notification(
    notification_id: int,
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    """Delete a single notification"""
    try:
        from models.database_models import NotificationQueue
        
        # Verify token
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Find and delete notification
        notif = db.query(NotificationQueue).filter(
            NotificationQueue.id == notification_id
        ).first()
        
        if not notif:
            raise HTTPException(status_code=404, detail="Notification not found")
        
        db.delete(notif)
        db.commit()
        
        logger.info(f"Deleted notification {notification_id}")
        
        return {
            "success": True,
            "message": "Notification deleted"
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting notification: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.delete("")
async def delete_all_notifications(
    authorization: Optional[str] = Header(None),
    db: Session = Depends(get_db)
):
    """Delete all notifications"""
    try:
        from models.database_models import NotificationQueue
        
        # Verify token
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Delete all notifications
        deleted_count = db.query(NotificationQueue).delete()
        db.commit()
        
        logger.info(f"Deleted all {deleted_count} notifications")
        
        return {
            "success": True,
            "message": f"Deleted {deleted_count} notifications"
        }
    except HTTPException:
        raise
    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting all notifications: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "notification-microservice"}
