"""API routes for notification microservice"""
import logging
import json
from typing import Optional
from datetime import datetime, timezone
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
    """Fetch ONLY the authenticated doctor's notifications - returns Flutter NotificationLogModel format"""
    try:
        from models.database_models import NotificationQueue, Doctor
        
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
        
        logger.info(f"Fetching notifications for authenticated doctor: {email}")
        
        # ===== Look up doctor_id from DOCTOR table by EMAIL =====
        doctor_id = None
        try:
            doctor = db.query(Doctor).filter(Doctor.email == email).first()
            if doctor:
                doctor_id = doctor.id
                logger.info(f"Authenticated doctor {email} has doctor_id: {doctor_id}")
            else:
                logger.warning(f"Doctor not found in DOCTOR table for email: {email}")
                # Use email hash as fallback identifier
                import hashlib
                doctor_id = int(hashlib.md5(email.encode()).hexdigest()[:8], 16) % 1000000
                logger.info(f"Using fallback doctor_id (hash): {doctor_id} for {email}")
        except Exception as e:
            logger.error(f"Error querying DOCTOR table: {e}")
            # Graceful fallback: use email hash
            import hashlib
            doctor_id = int(hashlib.md5(email.encode()).hexdigest()[:8], 16) % 1000000
            logger.warning(f"Using fallback doctor_id (hash): {doctor_id} for email: {email}")
        
        # ===== CRITICAL: Filter by doctor_id to show ONLY this doctor's notifications =====
        query = db.query(NotificationQueue).filter(
            NotificationQueue.user_id == doctor_id
        ).order_by(
            NotificationQueue.created_at.desc()
        )
        
        total_count = query.count()
        notifications = query.limit(limit).offset(offset).all()
        
        logger.info(f"Doctor {email} (id: {doctor_id}) has {total_count} notifications, returning {len(notifications)}")
        
        # Format response to match Flutter NotificationLogModel structure
        data = []
        for notif in notifications:
            payload_obj = json.loads(notif.payload) if notif.payload else {}
            
            # Determine notification type based on payload content
            is_doctor_notification = "patientId" in payload_obj or "patient_name" in payload_obj
            
            # Extract fields intelligently based on notification direction
            if is_doctor_notification:
                # This is a doctor being notified - show patient info
                notification_item = {
                    "id": notif.id,
                    "title": payload_obj.get("title", "Notification"),
                    "body": payload_obj.get("body", ""),
                    "readStatus": notif.status == "DELIVERED",
                    "createdAt": notif.created_at.isoformat() if notif.created_at else None,
                    "appointmentId": payload_obj.get("appointmentId"),
                    "messageId": notif.fcm_message_id,
                    "doctorId": payload_obj.get("doctor_id"),
                    "type": payload_obj.get("type", "appointment"),
                    "time": payload_obj.get("time"),
                    "clinic": payload_obj.get("clinic"),
                    "doctorName": payload_obj.get("doctor_name")
                }
            else:
                # This is a patient being notified - show doctor info
                notification_item = {
                    "id": notif.id,
                    "title": payload_obj.get("title", "Notification"),
                    "body": payload_obj.get("body", ""),
                    "readStatus": notif.status == "DELIVERED",
                    "createdAt": notif.created_at.isoformat() if notif.created_at else None,
                    "appointmentId": payload_obj.get("appointmentId"),
                    "messageId": notif.fcm_message_id,
                    "doctorId": payload_obj.get("doctorId"),
                    "type": payload_obj.get("type", "appointment"),
                    "time": payload_obj.get("time"),
                    "clinic": payload_obj.get("location") or payload_obj.get("clinic"),
                    "doctorName": payload_obj.get("doctor_name") or payload_obj.get("doctorName")
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
    """Mark a single notification as read (must be doctor's own notification)"""
    try:
        from models.database_models import NotificationQueue, Doctor
        
        # Verify token
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Get doctor by email
        email = payload.get('sub')
        try:
            doctor = db.query(Doctor).filter(Doctor.email == email).first()
            doctor_id = doctor.id if doctor else None
        except:
            doctor_id = None
        
        if not doctor_id:
            import hashlib
            doctor_id = int(hashlib.md5(email.encode()).hexdigest()[:8], 16) % 1000000
        
        # Find notification and verify it belongs to this doctor
        notif = db.query(NotificationQueue).filter(
            NotificationQueue.id == notification_id,
            NotificationQueue.user_id == doctor_id  # CRITICAL: Verify ownership
        ).first()
        
        if not notif:
            raise HTTPException(status_code=404, detail="Notification not found or does not belong to you")
        
        notif.status = "DELIVERED"
        notif.updated_at = datetime.now(timezone.utc)
        db.commit()
        
        logger.info(f"User {email} marked notification {notification_id} as read")
        
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
    """Mark all THIS DOCTOR's notifications as read"""
    try:
        from models.database_models import NotificationQueue, Doctor
        
        # Verify token
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Get doctor by email
        email = payload.get('sub')
        try:
            doctor = db.query(Doctor).filter(Doctor.email == email).first()
            doctor_id = doctor.id if doctor else None
        except:
            doctor_id = None
        
        if not doctor_id:
            import hashlib
            doctor_id = int(hashlib.md5(email.encode()).hexdigest()[:8], 16) % 1000000
        
        # Update ONLY this doctor's PENDING notifications to DELIVERED
        updated_count = db.query(NotificationQueue).filter(
            NotificationQueue.user_id == doctor_id,  # CRITICAL: Filter by doctor
            NotificationQueue.status == "PENDING"
        ).update({"status": "DELIVERED", "updated_at": datetime.now(timezone.utc)})
        
        db.commit()
        
        logger.info(f"User {email} marked {updated_count} notifications as read")
        
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
    """Delete a single notification (must be doctor's own notification)"""
    try:
        from models.database_models import NotificationQueue, Doctor
        
        # Verify token
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Get doctor by email
        email = payload.get('sub')
        try:
            doctor = db.query(Doctor).filter(Doctor.email == email).first()
            doctor_id = doctor.id if doctor else None
        except:
            doctor_id = None
        
        if not doctor_id:
            import hashlib
            doctor_id = int(hashlib.md5(email.encode()).hexdigest()[:8], 16) % 1000000
        
        # Find notification and verify it belongs to this doctor
        notif = db.query(NotificationQueue).filter(
            NotificationQueue.id == notification_id,
            NotificationQueue.user_id == doctor_id  # CRITICAL: Verify ownership
        ).first()
        
        if not notif:
            raise HTTPException(status_code=404, detail="Notification not found or does not belong to you")
        
        db.delete(notif)
        db.commit()
        
        logger.info(f"User {email} deleted notification {notification_id}")
        
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
    """Delete all THIS DOCTOR's notifications"""
    try:
        from models.database_models import NotificationQueue, Doctor
        
        # Verify token
        if not authorization:
            raise HTTPException(status_code=401, detail="Authorization token required")
        
        token = authorization.replace("Bearer ", "").replace("bearer ", "").strip()
        payload = decode_jwt_payload(token)
        if not payload:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        # Get doctor by email
        email = payload.get('sub')
        try:
            doctor = db.query(Doctor).filter(Doctor.email == email).first()
            doctor_id = doctor.id if doctor else None
        except:
            doctor_id = None
        
        if not doctor_id:
            import hashlib
            doctor_id = int(hashlib.md5(email.encode()).hexdigest()[:8], 16) % 1000000
        
        # Delete only this doctor's notifications
        deleted_count = db.query(NotificationQueue).filter(
            NotificationQueue.user_id == doctor_id  # CRITICAL: Only delete doctor's own
        ).delete()
        db.commit()
        
        logger.info(f"User {email} deleted all {deleted_count} notifications")
        
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
