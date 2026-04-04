"""Patient temporary token model for viewing notifications without permanent login"""
from sqlalchemy import Column, Integer, String, DateTime, Boolean, Index
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime, timedelta
import secrets

Base = declarative_base()

class PatientTempToken(Base):
    """
    Temporary single-use tokens for patients to view their appointment notifications
    
    Flow:
      1. Appointment booked → Token generated with patient details
      2. Patient receives token via SMS/email
      3. Patient enters token + views their notification
      4. Token marked as USED or automatically expires
      5. Next appointment → New token generated
    
    Benefits:
      - No permanent password needed
      - Time-limited access
      - Traceable (which token was used when)
      - Auto-cleanup of expired tokens
    """
    __tablename__ = "PATIENT_TEMP_TOKEN"
    
    id = Column(Integer, primary_key=True)
    
    # The actual token string (6 digits or short alphanumeric)
    token = Column(String(50), unique=True, nullable=False, index=True)
    
    # Patient information
    patient_id = Column(Integer, nullable=False, index=True)
    patient_first_name = Column(String(100))
    patient_last_name = Column(String(100))
    patient_email = Column(String(255))
    patient_phone = Column(String(20))
    
    # Appointment reference
    appointment_id = Column(Integer, nullable=False, index=True)
    clinic_name = Column(String(255))
    clinic_location = Column(String(255))
    appointment_date = Column(DateTime)
    
    # Token lifecycle
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    expires_at = Column(DateTime, nullable=False, index=True)  # Auto-expires
    
    # Usage tracking
    is_used = Column(Boolean, default=False, index=True)
    used_at = Column(DateTime)
    
    # Security: Track if token was viewed/accessed
    accessed_at = Column(DateTime)
    access_count = Column(Integer, default=0)
    
    __table_args__ = (
        Index('IDX_TOKEN_PATIENT', 'patient_id', 'appointment_id'),
        Index('IDX_TOKEN_EXPIRY', 'expires_at'),
        Index('IDX_TOKEN_STATUS', 'is_used', 'expires_at'),
    )
    
    @staticmethod
    def generate_token(length: int = 6) -> str:
        """Generate a 6-digit numeric token easy for patients to share"""
        return ''.join([str(i) for i in [secrets.randbelow(10) for _ in range(length)]])
    
    @staticmethod
    def generate_alphanumeric_token(length: int = 8) -> str:
        """Generate alphanumeric token for more security"""
        return secrets.token_urlsafe(length)
    
    def is_valid(self) -> bool:
        """Check if token is still valid"""
        now = datetime.utcnow()
        return not self.is_used and now < self.expires_at
    
    def mark_as_used(self):
        """Mark token as used"""
        self.is_used = True
        self.used_at = datetime.utcnow()
    
    def record_access(self):
        """Record that token was accessed"""
        self.accessed_at = datetime.utcnow()
        self.access_count += 1
