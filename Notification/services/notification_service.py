"""Main notification service orchestrator"""
import logging
from typing import Optional, Dict, List
from datetime import datetime
from sqlalchemy.orm import Session
from services.queue_service import QueueService
from services.email_service import EmailService
from services.patient_token_service import PatientTokenService
from utils.idempotency import generate_idempotency_key

logger = logging.getLogger(__name__)

class NotificationService:
    """Orchestrate notifications for patients and doctors"""
    
    def __init__(self, db: Session):
        self.db = db
        self.queue_service = QueueService(db)
        self.email_service = EmailService()
        self.patient_token_service = PatientTokenService(db)
    
    def notify_appointment_confirmed(self, appointment_id: int, 
                                    patient_id: int, patient_name: str,
                                    doctor_id: int, doctor_name: str,
                                    category: str = "General", location: str = "Clinic") -> Dict:
        """
        Notify both patient and doctor about appointment confirmation
        
        Args:
            appointment_id: ID of the appointment
            patient_id: ID of the patient
            patient_name: Name of the patient (provided by Java backend)
            doctor_id: ID of the doctor
            doctor_name: Name of the doctor (provided by Java backend)
            category: Medical category/specialty of the doctor
            location: City or location of the clinic
        
        Returns:
            Dictionary with notification status for patient and doctor
        """
        results = {"patient": None, "doctor": None}
        
        try:
            # === Notify PATIENT: Show doctor name, category, and location ===
            patient_key = generate_idempotency_key(f"apt_confirm_{appointment_id}_patient")
            patient_title = f"{doctor_name} - {category}"
            patient_body = f"Your appointment at {location}"
            patient_payload = {
                "title": patient_title,
                "body": patient_body,
                "appointmentId": str(appointment_id),
                "doctorId": str(doctor_id),
                "doctor_name": doctor_name,
                "category": category,
                "location": location,
                "type": "APPOINTMENT_CONFIRMED",
                "time": None  # Set when appointment time is known
            }
            self.queue_service.enqueue(
                patient_id, 
                patient_title,
                patient_body,
                patient_key,
                patient_payload
            )
            results["patient"] = "queued"
            
            # === AUTO-GENERATE TEMPORARY TOKEN FOR PATIENT ===
            # Patient gets a 6-digit code via SMS to view appointment without login
            try:
                patient_token = self.patient_token_service.generate_token(
                    patient_id=patient_id,
                    patient_first_name=patient_name.split()[0] if patient_name else "Patient",
                    patient_last_name=patient_name.split()[-1] if patient_name and len(patient_name.split()) > 1 else "",
                    appointment_id=appointment_id,
                    clinic_name="Clinic",
                    clinic_location=location,
                    expires_in_hours=24
                )
                results["patient_token"] = patient_token.token
                logger.info(f"Generated temp token {patient_token.token} for patient {patient_id}")
                # TODO: Send token via SMS: send_sms(patient_phone, f"Your appointment token: {patient_token.token}")
            except Exception as e:
                logger.error(f"Failed to generate patient token: {e}")
                results["patient_token"] = None
            
            # === Notify DOCTOR: Show that someone has been appointed with them ===
            doctor_key = generate_idempotency_key(f"apt_confirm_{appointment_id}_doctor")
            doctor_title = "تم حجز موعد جديد"
            doctor_body = f"You have a new appointment with {patient_name}"
            # Doctor notification should include patient info clearly
            doctor_payload = {
                "title": doctor_title,
                "body": doctor_body,
                "appointmentId": str(appointment_id),
                "patientId": str(patient_id),
                "patient_name": patient_name,
                # Include doctor's own info so app can display it if needed
                "doctor_id": str(doctor_id),
                "doctor_name": None,  # Doctor already knows their own name
                # Include clinic/location info if available
                "location": location,
                "clinic": location,
                "type": "APPOINTMENT_CONFIRMED",
                "time": None  # Set when appointment time is known
            }
            self.queue_service.enqueue(
                doctor_id,
                doctor_title,
                doctor_body,
                doctor_key,
                doctor_payload
            )
            results["doctor"] = "queued"
            
            logger.info(f"Appointment {appointment_id} confirmation notifications queued - Patient: {patient_name}, Doctor: {doctor_name}")
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
            patient_title = "Appointment Reminder"
            patient_body = f"Reminder: You have an appointment with {doctor_name}"
            self.queue_service.enqueue(
                patient_id,
                patient_title,
                patient_body,
                patient_key,
                {
                    "title": patient_title,
                    "body": patient_body,
                    "appointmentId": str(appointment_id),
                    "doctorId": str(doctor_id),
                    "doctor_name": doctor_name,
                    "type": "APPOINTMENT_REMINDER"
                }
            )
            results["patient"] = "queued"
            
            # Notify doctor of upcoming appointment
            doctor_key = generate_idempotency_key(f"apt_reminder_{appointment_id}_doctor")
            doctor_title = "Appointment Reminder"
            doctor_body = f"Reminder: You have an appointment with {patient_name}"
            self.queue_service.enqueue(
                doctor_id,
                doctor_title,
                doctor_body,
                doctor_key,
                {
                    "title": doctor_title,
                    "body": doctor_body,
                    "appointmentId": str(appointment_id),
                    "patientId": str(patient_id),
                    "patient_name": patient_name,
                    "doctor_id": str(doctor_id),
                    "doctor_name": None,
                    "location": None,
                    "clinic": None,
                    "type": "APPOINTMENT_REMINDER"
                }
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
            title = "Treatment Plan Updated"
            body = "Your dental treatment plan has been updated. Please review it."
            self.queue_service.enqueue(
                patient_id,
                title,
                body,
                key,
                {
                    "title": title,
                    "body": body,
                    "treatmentPlanId": str(treatment_plan_id),
                    "type": "TREATMENT_UPDATED"
                }
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
            title = "Payment Received"
            body = f"Your payment of {amount} {currency} has been received."
            self.queue_service.enqueue(
                patient_id,
                title,
                body,
                key,
                {
                    "title": title,
                    "body": body,
                    "amount": amount,
                    "currency": currency,
                    "type": "PAYMENT_RECEIVED"
                }
            )
            
            logger.info(f"Payment receipt notification queued for patient {patient_id}")
            return "queued"
            
        except Exception as e:
            logger.error(f"Error notifying payment: {e}")
            raise
