"""API routes for notification microservice"""
import logging
from fastapi import APIRouter, HTTPException, Depends, BackgroundTasks
from sqlalchemy.orm import Session
from models.schemas import (
    AppointmentNotificationRequest,
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
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """Queue appointment confirmation notification"""
    try:
        validate_idempotency(request.idempotency_key)
        
        notification_service = NotificationService(db)
        result = notification_service.notify_appointment_confirmed(
            request.appointment_id,
            request.patient_id,
            request.doctor_id
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
    patient_id: int,
    treatment_plan_id: int,
    db: Session = Depends(get_db)
):
    """Notify patient about treatment plan update"""
    try:
        notification_service = NotificationService(db)
        status = notification_service.notify_treatment_plan_update(
            patient_id,
            treatment_plan_id
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
    patient_id: int,
    amount: str,
    db: Session = Depends(get_db)
):
    """Notify patient about payment receipt"""
    try:
        notification_service = NotificationService(db)
        status = notification_service.notify_payment_received(
            patient_id,
            amount
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

@router.post("/health-check")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "notification-microservice"}
