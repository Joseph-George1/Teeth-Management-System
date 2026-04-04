"""Email notification service"""
import logging
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from typing import List, Optional
from config.email_config import EmailConfig

logger = logging.getLogger(__name__)

class EmailService:
    """Send email notifications"""
    
    def __init__(self):
        self.config = EmailConfig()
    
    def send_appointment_confirmation_email(self, 
                                           patient_email: str,
                                           patient_name: str,
                                           doctor_name: str,
                                           appointment_date: str,
                                           appointment_time: str) -> bool:
        """Send appointment confirmation email to patient"""
        try:
            subject = "Appointment Confirmation"
            body = f"""
            Dear {patient_name},
            
            Your dental appointment has been confirmed.
            
            Doctor: {doctor_name}
            Date: {appointment_date}
            Time: {appointment_time}
            
            If you need to reschedule, please contact us at least 24 hours before your appointment.
            
            Best regards,
            Dental Clinic
            """
            
            return self._send_email(patient_email, subject, body)
        except Exception as e:
            logger.error(f"Failed to send appointment confirmation email: {e}")
            return False
    
    def send_password_reset_email(self, email: str, reset_link: str) -> bool:
        """Send password reset email"""
        try:
            subject = "Password Reset Request"
            body = f"""
            We received a request to reset your password.
            
            Please click the link below to reset your password:
            {reset_link}
            
            This link will expire in 24 hours.
            
            If you didn't request this, please ignore this email.
            
            Best regards,
            Dental Clinic
            """
            
            return self._send_email(email, subject, body)
        except Exception as e:
            logger.error(f"Failed to send password reset email: {e}")
            return False
    
    def send_appointment_reminder_email(self,
                                       patient_email: str,
                                       patient_name: str,
                                       doctor_name: str,
                                       appointment_date: str,
                                       appointment_time: str) -> bool:
        """Send appointment reminder email"""
        try:
            subject = "Appointment Reminder"
            body = f"""
            Dear {patient_name},
            
            This is a reminder about your upcoming dental appointment.
            
            Doctor: {doctor_name}
            Date: {appointment_date}
            Time: {appointment_time}
            
            Please arrive 10 minutes early.
            
            Best regards,
            Dental Clinic
            """
            
            return self._send_email(patient_email, subject, body)
        except Exception as e:
            logger.error(f"Failed to send reminder email: {e}")
            return False
    
    def _send_email(self, to_email: str, subject: str, body: str) -> bool:
        """Internal method to send email"""
        try:
            msg = MIMEMultipart()
            msg['From'] = self.config.SENDER_EMAIL
            msg['To'] = to_email
            msg['Subject'] = subject
            
            msg.attach(MIMEText(body, 'plain'))
            
            # TODO: Implement SMTP connection based on configuration
            # For now, log the email
            logger.info(f"Email would be sent to {to_email}: {subject[:50]}...")
            
            return True
        except Exception as e:
            logger.error(f"Error sending email to {to_email}: {e}")
            return False
