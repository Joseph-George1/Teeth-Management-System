"""Main notification service orchestrator"""
import logging
from typing import Optional, Dict, List
from sqlalchemy.orm import Session
from models.database_models import DoctorProfile, PatientProfile
from services.queue_service import QueueService
from services.email_service import EmailService
from utils.idempotency import generate_idempotency_key
from config.notification_config import NotificationConfig

logger = logging.getLogger(__name__)

class NotificationService:
    """Orchestrate notifications for patients and doctors"""
    
    def __init__(self, db: Session):
        self.db = db
        self.queue_service = QueueService(db)
        self.email_service = EmailService()
        self.config = NotificationConfig()
    
    def notify_appointment_confirmed(self, appointment_id: int, 
                                    patient_id: int, doctor_id: int) -> Dict:
        """Notify both patient and doctor about appointment confirmation"""
        results = {"patient": None, "doctor": None}
        
        try:
            # Get patient and doctor details
            patient = self.db.query(PatientProfile).filter(
                PatientProfile.user_id == patient_id
            ).first()
            doctor = self.db.query(DoctorProfile).filter(
                DoctorProfile.user_id == doctor_id
            ).first()
            
            if not patient or not doctor:
                raise ValueError("Patient or doctor not found")
            
            # Notify patient
            patient_key = generate_idempotency_key(f"apt_confirm_{appointment_id}_patient")
            patient_payload = {
                "appointment_id": appointment_id,
                "doctor_name": doctor.name,
                "type": "APPOINTMENT_CONFIRMED"
            }
            self.queue_service.enqueue(
                patient_id, 
                "Appointment Confirmed",
                f"Your appointment with {doctor.name} has been confirmed",
                patient_key,
                patient_payload
            )
            results["patient"] = "queued"
            
            # Notify doctor
            doctor_key = generate_idempotency_key(f"apt_confirm_{appointment_id}_doctor")
            doctor_payload = {
                "appointment_id": appointment_id,
                "patient_name": patient.name,
                "type": "APPOINTMENT_CONFIRMED"
            }
            self.queue_service.enqueue(
                doctor_id,
                "New Appointment",
                f"You have a new appointment with {patient.name}",
                doctor_key,
                doctor_payload
            )
            results["doctor"] = "queued"
            
            logger.info(f"Appointment {appointment_id} confirmation notifications queued")
            return results
            
        except Exception as e:
            logger.error(f"Error notifying appointment confirmation: {e}")
            raise
    
    def notify_appointment_reminder(self, appointment_id: int) -> Dict:
        """Send appointment reminders to patient and doctor"""
        logger.info(f"Processing reminder for appointment {appointment_id}")
        results = {}
        
        # TODO: Implement reminder logic with time-based checks
        return results
    
    def notify_treatment_plan_update(self, patient_id: int, 
                                      treatment_plan_id: int) -> str:
        """Notify patient about treatment plan update"""
        try:
            patient = self.db.query(PatientProfile).filter(
                PatientProfile.user_id == patient_id
            ).first()
            
            if not patient:
                raise ValueError("Patient not found")
            
            key = generate_idempotency_key(f"treatment_{treatment_plan_id}_patient")
            self.queue_service.enqueue(
                patient_id,
                "Treatment Plan Updated",
                "Your dental treatment plan has been updated. Please review it.",
                key,
                {"treatment_plan_id": treatment_plan_id, "type": "TREATMENT_UPDATED"}
            )
            
            return "queued"
            
        except Exception as e:
            logger.error(f"Error notifying treatment plan update: {e}")
            raise
    
    def notify_payment_received(self, patient_id: int, amount: str) -> str:
        """Notify patient about payment receipt"""
        try:
            patient = self.db.query(PatientProfile).filter(
                PatientProfile.user_id == patient_id
            ).first()
            
            if not patient:
                raise ValueError("Patient not found")
            
            key = generate_idempotency_key(f"payment_{patient_id}_{amount}")
            self.queue_service.enqueue(
                patient_id,
                "Payment Received",
                f"Your payment of {amount} has been received.",
                key,
                {"amount": amount, "type": "PAYMENT_RECEIVED"}
            )
            
            return "queued"
            
        except Exception as e:
            logger.error(f"Error notifying payment: {e}")
            raise
