"""Patient temporary token management service"""
import logging
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from sqlalchemy import and_
from models.patient_token_model import PatientTempToken

logger = logging.getLogger(__name__)

class PatientTokenService:
    """Manage temporary tokens for patient notification access"""
    
    def __init__(self, db: Session):
        self.db = db
    
    def generate_token(self, patient_id: int, patient_first_name: str, 
                      patient_last_name: str, appointment_id: int,
                      patient_email: str = None, patient_phone: str = None,
                      clinic_name: str = None, clinic_location: str = None,
                      appointment_time: datetime = None,
                      expires_in_hours: int = 24) -> PatientTempToken:
        """
        Generate a temporary token for a patient to access their appointment notification
        
        Args:
            patient_id: ID of the patient
            patient_first_name: Patient's first name
            patient_last_name: Patient's last name
            appointment_id: ID of the appointment this token is for
            patient_email: Patient's email (optional, for sending token)
            patient_phone: Patient's phone (optional, for sending token)
            clinic_name: Name of clinic (optional, for context)
            clinic_location: Location of clinic (optional, for context)
            appointment_time: When the appointment is scheduled (optional)
            expires_in_hours: How many hours until token expires (default: 24)
        
        Returns:
            PatientTempToken object with generated token
        """
        try:
            # Generate token (6 digits: easy to share via SMS)
            token_string = PatientTempToken.generate_token(length=6)
            
            # Check for uniqueness (rare collision, but be safe)
            while self.db.query(PatientTempToken).filter(
                PatientTempToken.token == token_string
            ).first():
                token_string = PatientTempToken.generate_token(length=6)
            
            # Create token
            token = PatientTempToken(
                token=token_string,
                patient_id=patient_id,
                patient_first_name=patient_first_name,
                patient_last_name=patient_last_name,
                patient_email=patient_email,
                patient_phone=patient_phone,
                appointment_id=appointment_id,
                clinic_name=clinic_name,
                clinic_location=clinic_location,
                appointment_time=appointment_time,
                created_at=datetime.utcnow(),
                expires_at=datetime.utcnow() + timedelta(hours=expires_in_hours),
                is_used=False
            )
            
            self.db.add(token)
            self.db.commit()
            
            logger.info(f"Generated temp token {token_string} for patient {patient_id} "
                       f"(appointment {appointment_id}, expires in {expires_in_hours}h)")
            
            return token
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Failed to generate patient token: {e}")
            raise
    
    def validate_token(self, token_string: str) -> PatientTempToken:
        """
        Validate a patient token
        
        Args:
            token_string: The token to validate (6-digit code from SMS)
        
        Returns:
            PatientTempToken if valid, None if invalid/expired/used
        """
        try:
            token = self.db.query(PatientTempToken).filter(
                PatientTempToken.token == token_string
            ).first()
            
            if not token:
                logger.warning(f"Token not found: {token_string}")
                return None
            
            if not token.is_valid():
                logger.warning(f"Token expired or already used: {token_string}")
                return None
            
            return token
            
        except Exception as e:
            logger.error(f"Error validating token: {e}")
            return None
    
    def use_token(self, token_string: str) -> PatientTempToken:
        """
        Mark a token as used (after patient has viewed their notification)
        
        Args:
            token_string: The token to mark as used
        
        Returns:
            Updated PatientTempToken or None if invalid
        """
        try:
            token = self.validate_token(token_string)
            if not token:
                return None
            
            token.record_access()
            token.mark_as_used()
            self.db.commit()
            
            logger.info(f"Marked token {token_string} as used for patient {token.patient_id}")
            
            return token
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error using token: {e}")
            return None
    
    def access_token(self, token_string: str) -> PatientTempToken:
        """
        Record that a token was accessed (viewed notifications)
        Does NOT mark as used yet - patient can view multiple times within expiry
        
        Args:
            token_string: The token being accessed
        
        Returns:
            Updated PatientTempToken or None if invalid
        """
        try:
            token = self.validate_token(token_string)
            if not token:
                return None
            
            token.record_access()
            self.db.commit()
            
            logger.info(f"Token {token_string} accessed by patient {token.patient_id} "
                       f"(access #{token.access_count})")
            
            return token
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error recording token access: {e}")
            return None
    
    def revoke_token(self, token_string: str) -> bool:
        """
        Manually revoke a token (e.g., if appointment cancelled)
        
        Args:
            token_string: The token to revoke
        
        Returns:
            True if revoked, False if not found
        """
        try:
            token = self.db.query(PatientTempToken).filter(
                PatientTempToken.token == token_string
            ).first()
            
            if not token:
                return False
            
            # Mark as used to prevent further access
            token.is_used = True
            self.db.commit()
            
            logger.info(f"Revoked token {token_string}")
            
            return True
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error revoking token: {e}")
            return False
    
    def cleanup_expired_tokens(self) -> int:
        """
        Delete tokens that have expired
        Runs periodically (via APScheduler or manually)
        
        Returns:
            Number of tokens deleted
        """
        try:
            now = datetime.utcnow()
            
            deleted_count = self.db.query(PatientTempToken).filter(
                PatientTempToken.expires_at <= now
            ).delete()
            
            self.db.commit()
            
            if deleted_count > 0:
                logger.info(f"Cleaned up {deleted_count} expired patient tokens")
            
            return deleted_count
            
        except Exception as e:
            self.db.rollback()
            logger.error(f"Error cleaning up expired tokens: {e}")
            return 0
    
    def get_patient_active_tokens(self, patient_id: int) -> list:
        """Get all active (non-expired, non-used) tokens for a patient"""
        try:
            now = datetime.utcnow()
            tokens = self.db.query(PatientTempToken).filter(
                and_(
                    PatientTempToken.patient_id == patient_id,
                    PatientTempToken.is_used == False,
                    PatientTempToken.expires_at > now
                )
            ).all()
            
            return tokens
            
        except Exception as e:
            logger.error(f"Error fetching patient tokens: {e}")
            return []
