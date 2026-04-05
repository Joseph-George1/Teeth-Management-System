"""Patient temporary token model for viewing notifications without permanent login"""
from sqlalchemy import Column, Integer, String, DateTime, Sequence, text
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime, timedelta, timezone
import secrets

Base = declarative_base()

# Oracle sequence that matches the database
patient_token_seq = Sequence('seq_patient_token_id', optional=True)

class PatientTempToken(Base):
    """
    Temporary single-use tokens for patients to view their appointment notifications
    
    Matches EXACTLY the working Oracle schema:
    - id: Primary key, auto-generated from seq_patient_token_id
    - token: VARCHAR2(255), NOT NULL
    - All patient/appointment fields: nullable
    - created_at: TIMESTAMP with CURRENT_TIMESTAMP default
    - expires_at: TIMESTAMP, nullable
    - is_used: NUMBER(1) (Integer with values 0/1)
    - access tracking: accessed_at, access_count
    """
    __tablename__ = "PATIENT_TEMP_TOKEN"
    
    # Primary key using sequence
    id = Column(Integer, patient_token_seq, primary_key=True)
    
    # Token string (VARCHAR2(255), NOT NULL)
    token = Column(String(255), nullable=False, index=True)
    
    # Patient information (all nullable)
    patient_id = Column(Integer, index=True)
    patient_first_name = Column(String(255))
    patient_last_name = Column(String(255))
    patient_email = Column(String(255))
    patient_phone = Column(String(255))
    
    # Appointment reference (all nullable)
    appointment_id = Column(Integer, index=True)
    clinic_name = Column(String(255))
    clinic_location = Column(String(255))
    appointment_time = Column(DateTime)
    
    # Token lifecycle (TIMESTAMP columns)
    created_at = Column(DateTime, server_default=text("CURRENT_TIMESTAMP"), index=True)
    expires_at = Column(DateTime)
    
    # Usage tracking (NUMBER(1) = Integer with 0/1 values)
    is_used = Column(Integer, default=0, index=True)
    used_at = Column(DateTime)
    
    # Access tracking
    accessed_at = Column(DateTime)
    access_count = Column(Integer, default=0)
    
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
        now = datetime.now(timezone.utc)
        return self.is_used == 0 and now < self.expires_at
    
    def mark_as_used(self):
        """Mark token as used"""
        self.is_used = 1
        self.used_at = datetime.now(timezone.utc)
    
    def record_access(self):
        """Record that token was accessed"""
        self.accessed_at = datetime.now(timezone.utc)
        self.access_count += 1
