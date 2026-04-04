"""Patient notification endpoints - No login required, just use temp token"""
import logging
import json
from typing import Optional
from datetime import datetime
from fastapi import APIRouter, HTTPException, Header
from sqlalchemy.orm import Session
from sqlalchemy import and_
from models.patient_token_model import PatientTempToken
from models.database_models import NotificationQueue
from services.patient_token_service import PatientTokenService
from utils.database import get_db
from fastapi import Depends

logger = logging.getLogger(__name__)
router = APIRouter(prefix="/api/v1/patient", tags=["patient-notifications"])

# =========================================================================
# SIMPLE PATIENT ACCESS - No login, just phone number or appointment ID
# =========================================================================

@router.get("/token")
async def get_patient_token(
    phone: Optional[str] = None,
    appointment_id: Optional[int] = None,
    db: Session = Depends(get_db)
):
    """
    Get patient's temporary token using:
    - Phone number (e.g., +201001234567)
    - OR Appointment ID (e.g., 10956)
    
    Returns the latest active token so patient can view their notification
    """
    try:
        if not phone and not appointment_id:
            raise HTTPException(
                status_code=400, 
                detail="Provide either 'phone' or 'appointment_id'"
            )
        
        token_service = PatientTokenService(db)
        
        # Find token by phone number
        if phone:
            token = db.query(PatientTempToken).filter(
                and_(
                    PatientTempToken.patient_phone == phone,
                    PatientTempToken.is_used == False,
                    PatientTempToken.expires_at > datetime.utcnow()
                )
            ).order_by(
                PatientTempToken.created_at.desc()
            ).first()
            
            if not token:
                raise HTTPException(
                    status_code=404,
                    detail=f"No active token found for phone: {phone}. Try appointment_id instead."
                )
            
            logger.info(f"Patient retrieved token via phone: {phone}")
        
        # Find token by appointment ID
        elif appointment_id:
            token = db.query(PatientTempToken).filter(
                and_(
                    PatientTempToken.appointment_id == appointment_id,
                    PatientTempToken.is_used == False,
                    PatientTempToken.expires_at > datetime.utcnow()
                )
            ).order_by(
                PatientTempToken.created_at.desc()
            ).first()
            
            if not token:
                raise HTTPException(
                    status_code=404,
                    detail=f"No active token found for appointment: {appointment_id}"
                )
            
            logger.info(f"Patient retrieved token via appointment: {appointment_id}")
        
        # Return token info (NOT marking as used yet)
        token_service.access_token(token.token)
        
        return {
            "success": True,
            "token": token.token,
            "patient_name": f"{token.patient_first_name} {token.patient_last_name}",
            "appointment_id": token.appointment_id,
            "clinic_name": token.clinic_name,
            "clinic_location": token.clinic_location,
            "appointment_date": token.appointment_date.isoformat() if token.appointment_date else None,
            "expires_at": token.expires_at.isoformat(),
            "message": "Use this token to view your appointment notification"
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error retrieving patient token: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/notifications/{token}")
async def get_patient_notifications(
    token: str,
    db: Session = Depends(get_db)
):
    """
    Get patient's appointment notification using temporary token
    
    Usage:
    GET /api/v1/patient/notifications/123456?token=123456
    
    No login, no JWT, just the token!
    """
    try:
        token_service = PatientTokenService(db)
        
        # Validate token
        token_obj = token_service.validate_token(token)
        if not token_obj:
            raise HTTPException(
                status_code=401,
                detail="Invalid or expired token. Request a new one."
            )
        
        # Record access
        token_service.access_token(token)
        
        # Get patient's notifications for this appointment
        notifications = db.query(NotificationQueue).filter(
            NotificationQueue.user_id == token_obj.patient_id
        ).order_by(
            NotificationQueue.created_at.desc()
        ).all()
        
        logger.info(f"Patient {token_obj.patient_id} viewing {len(notifications)} notifications")
        
        # Format notifications
        data = []
        for notif in notifications:
            payload_obj = json.loads(notif.payload) if notif.payload else {}
            
            notification_item = {
                "id": notif.id,
                "title": payload_obj.get("title", "Notification"),
                "body": payload_obj.get("body", ""),
                "createdAt": notif.created_at.isoformat() if notif.created_at else None,
                "appointmentId": payload_obj.get("appointmentId"),
                "doctorName": payload_obj.get("doctor_name"),
                "clinic": payload_obj.get("location") or payload_obj.get("clinic"),
                "category": payload_obj.get("category")
            }
            data.append(notification_item)
        
        return {
            "success": True,
            "patient": f"{token_obj.patient_first_name} {token_obj.patient_last_name}",
            "clinic": token_obj.clinic_name,
            "notification_count": len(data),
            "data": data
        }
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error fetching patient notifications: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/token-validate")
async def validate_patient_token(
    token: str,
    db: Session = Depends(get_db)
):
    """
    Quick validation endpoint - check if token is valid
    Useful for mobile app to verify token before showing content
    """
    try:
        token_service = PatientTokenService(db)
        
        token_obj = token_service.validate_token(token)
        if not token_obj:
            return {
                "success": False,
                "valid": False,
                "message": "Token is invalid or expired"
            }
        
        return {
            "success": True,
            "valid": True,
            "patient_name": f"{token_obj.patient_first_name} {token_obj.patient_last_name}",
            "expires_at": token_obj.expires_at.isoformat(),
            "appointment_id": token_obj.appointment_id
        }
    except Exception as e:
        logger.error(f"Error validating token: {e}")
        return {
            "success": False,
            "valid": False,
            "message": "Server error"
        }
