"""API routes for notification microservice"""
import logging
from fastapi import APIRouter, HTTPException, Depends
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
    user_id: int = None,
    limit: int = 50,
    offset: int = 0,
    db: Session = Depends(get_db)
):
    """Fetch notifications for a user (most recent first)"""
    try:
        from models.database_models import NotificationQueue
        
        if not user_id:
            raise HTTPException(status_code=400, detail="user_id is required")
        
        # Query notifications for user, ordered by most recent first
        query = db.query(NotificationQueue).filter(
            NotificationQueue.user_id == user_id
        ).order_by(
            NotificationQueue.created_at.desc()
        )
        
        total_count = query.count()
        notifications = query.limit(limit).offset(offset).all()
        
        # Format response
        data = []
        for notif in notifications:
            import json
            payload = json.loads(notif.payload) if notif.payload else {}
            data.append({
                "id": notif.id,
                "title": payload.get("title", "Notification"),
                "body": payload.get("body", ""),
                "status": notif.status,
                "created_at": notif.created_at.isoformat() if notif.created_at else None,
                "updated_at": notif.updated_at.isoformat() if notif.updated_at else None,
                "payload": payload
            })
        
        return {
            "success": True,
            "data": data,
            "total_count": total_count,
            "limit": limit,
            "offset": offset
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching notifications: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "notification-microservice"}
