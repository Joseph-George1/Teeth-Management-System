"""Main notification service orchestrator"""
import logging
from typing import Optional, Dict, List
from sqlalchemy.orm import Session
from services.queue_service import QueueService
from services.email_service import EmailService
from utils.idempotency import generate_idempotency_key

logger = logging.getLogger(__name__)

class NotificationService:
    """Orchestrate notifications for patients and doctors"""
    
    def __init__(self, db: Session):
        self.db = db
        self.queue_service = QueueService(db)
        self.email_service = EmailService()
    
    def notify_appointment_confirmed(self, appointment_id: int, 
                                    patient_id: int, patient_name: str,
                                    doctor_id: int, doctor_name: str) -> Dict:
        """
        Notify both patient and doctor about appointment confirmation
        
        Args:
            appointment_id: ID of the appointment
            patient_id: ID of the patient
            patient_name: Name of the patient (provided by Java backend)
            doctor_id: ID of the doctor
            doctor_name: Name of the doctor (provided by Java backend)
        
        Returns:
            Dictionary with notification status for patient and doctor
        """
        results = {"patient": None, "doctor": None}
        
        try:
            # Notify patient
            patient_key = generate_idempotency_key(f"apt_confirm_{appointment_id}_patient")
            patient_payload = {
                "appointment_id": appointment_id,
                "doctor_name": doctor_name,
                "type": "APPOINTMENT_CONFIRMED"
            }
            self.queue_service.enqueue(
                patient_id, 
                "Appointment Confirmed",
                f"Your appointment with {doctor_name} has been confirmed",
                patient_key,
                patient_payload
            )
            results["patient"] = "queued"
            
            # Notify doctor
            doctor_key = generate_idempotency_key(f"apt_confirm_{appointment_id}_doctor")
            doctor_payload = {
                "appointment_id": appointment_id,
                "patient_name": patient_name,
                "type": "APPOINTMENT_CONFIRMED"
            }
            self.queue_service.enqueue(
                doctor_id,
                "New Appointment",
                f"You have a new appointment with {patient_name}",
                doctor_key,
                doctor_payload
            )
            results["doctor"] = "queued"
            
            logger.info(f"Appointment {appointment_id} confirmation notifications queued")
            return results
            
        except Exception as e:
            logger.error(f"Error notifying appointment confirmation: {e}")
            raise
    
    def notify_appointment_reminder(self, appointment_id: int, 
                                   patient_id: int, patient_name: str,
                                   doctor_id: int, doctor_name: str) -> Dict:
        """Send appointment reminders to patient and doctor"""
        logger.info(f"Processing reminder for appointment {appointment_id}")
        results = {}
        
        try:
            # Notify patient of upcoming appointment
            patient_key = generate_idempotency_key(f"apt_reminder_{appointment_id}_patient")
            self.queue_service.enqueue(
                patient_id,
                "Appointment Reminder",
                f"Reminder: You have an appointment with {doctor_name}",
                patient_key,
                {"appointment_id": appointment_id, "type": "APPOINTMENT_REMINDER"}
            )
            results["patient"] = "queued"
            
            # Notify doctor of upcoming appointment
            doctor_key = generate_idempotency_key(f"apt_reminder_{appointment_id}_doctor")
            self.queue_service.enqueue(
                doctor_id,
                "Appointment Reminder",
                f"Reminder: You have an appointment with {patient_name}",
                doctor_key,
                {"appointment_id": appointment_id, "type": "APPOINTMENT_REMINDER"}
            )
            results["doctor"] = "queued"
            
            return results
        except Exception as e:
            logger.error(f"Error sending appointment reminder: {e}")
            raise
    
    def notify_treatment_plan_update(self, patient_id: int, patient_name: str,
                                     treatment_plan_id: int) -> str:
        """
        Notify patient about treatment plan update
        
        Args:
            patient_id: ID of the patient
            patient_name: Name of the patient (provided by Java backend)
            treatment_plan_id: ID of the treatment plan
        
        Returns:
            Status string "queued"
        """
        try:
            key = generate_idempotency_key(f"treatment_{treatment_plan_id}_patient")
            self.queue_service.enqueue(
                patient_id,
                "Treatment Plan Updated",
                "Your dental treatment plan has been updated. Please review it.",
                key,
                {"treatment_plan_id": treatment_plan_id, "type": "TREATMENT_UPDATED"}
            )
            
            logger.info(f"Treatment plan {treatment_plan_id} update notification queued for patient {patient_id}")
            return "queued"
            
        except Exception as e:
            logger.error(f"Error notifying treatment plan update: {e}")
            raise
    
    def notify_payment_received(self, patient_id: int, patient_name: str,
                               amount: str, currency: str = "SAR") -> str:
        """
        Notify patient about payment receipt
        
        Args:
            patient_id: ID of the patient
            patient_name: Name of the patient (provided by Java backend)
            amount: Payment amount
            currency: Currency code (default: SAR)
        
        Returns:
            Status string "queued"
        """
        try:
            key = generate_idempotency_key(f"payment_{patient_id}_{amount}_{currency}")
            self.queue_service.enqueue(
                patient_id,
                "Payment Received",
                f"Your payment of {amount} {currency} has been received.",
                key,
                {"amount": amount, "currency": currency, "type": "PAYMENT_RECEIVED"}
            )
            
            logger.info(f"Payment receipt notification queued for patient {patient_id}")
            return "queued"
            
        except Exception as e:
            logger.error(f"Error notifying payment: {e}")
            raise
