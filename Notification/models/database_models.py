"""
SQLAlchemy ORM models for Oracle database
Maps notification tables to Python classes

Location: Notification/models/database_models.py
"""

from sqlalchemy import Column, Integer, String, DateTime, Text, LargeBinary, Boolean, ForeignKey, Index, Sequence, text
from sqlalchemy.ext.declarative import declarative_base
from datetime import datetime

Base = declarative_base()

# Oracle sequences
patient_device_token_seq = Sequence('seq_patient_device_tokens_id', optional=True)
user_id_seq = Sequence('seq_user_id', optional=True)  # For auto-generating user IDs

# =========================================================================
# TABLE 0: Doctor (Read-only mapping from main backend)
# Purpose: Map email addresses to doctor IDs for filtering notifications
# Features: Used to filter doctor notifications by authenticated user
# =========================================================================
class Doctor(Base):
    """
    Read-only mapping of doctors from DOCTOR table
    
    Allows us to:
      1. Look up doctor_id from email (from JWT token)
      2. Filter notifications to show only that doctor's messages
      3. Prevent information leak where one doctor sees all notifications
    """
    __tablename__ = "DOCTOR"
    
    # DOCTOR table only has ID and EMAIL columns
    id = Column(Integer, primary_key=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    
    __table_args__ = (
        Index('IDX_DOCTOR_EMAIL', 'email'),
    )

# =========================================================================
# TABLE 0.5: PatientDeviceToken
# Purpose: Store FCM device tokens for sending push notifications
# Features: Device type tracking, token validation, deduplication
# =========================================================================
class PatientDeviceToken(Base):
    """
    Store FCM device tokens linked to backend user IDs
    
    Each device (phone) must register with backend user_id to receive notifications.
    This ensures notification service and backend use IDENTICAL user IDs.
    
    Flow:
      1. Mobile app logs in to Java backend → receives user_id (e.g., 454)
      2. Mobile app registers device token with that user_id
      3. Token stored in PATIENT_DEVICE_TOKENS table linked to backend user_id
      4. Queue processor queries this table for user_id
      5. When backend sends notification to user_id=454, token is found
      6. Calls firebase_service.send_to_device(fcm_token, ...)
      7. FCM sends push to device ✓
      
    CRITICAL: user_id MUST come from backend - ensures perfect ID synchronization
    """
    __tablename__ = "PATIENT_DEVICE_TOKENS"
    
    id = Column(Integer, patient_device_token_seq, primary_key=True,
                server_default=text("seq_patient_device_tokens_id.NEXTVAL"))
    
    # User ID assigned at first device token registration - NEVER NULL
    user_id = Column(Integer, nullable=False, index=True)
    
    # The actual FCM token from mobile app - REQUIRED and UNIQUE
    fcm_token = Column(String(500), unique=True, nullable=False, index=True)
    
    # Device information
    device_type = Column(String(50))  # "android", "ios", etc.
    device_model = Column(String(100))  # "Samsung Galaxy S21", "iPhone 13", etc.
    os_version = Column(String(50))  # "12.0", "15.5", etc.
    app_version = Column(String(50))  # Version of the Teeth app
    
    # Token validity
    is_active = Column(Boolean, default=True, index=True)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    last_used_at = Column(DateTime)
    
    __table_args__ = (
        Index('IDX_DEVICE_USER_ACTIVE', 'user_id', 'is_active'),
        Index('IDX_DEVICE_TOKEN_ACTIVE', 'fcm_token', 'is_active'),
        Index('IDX_DEVICE_CREATED', 'created_at'),
    )

# =========================================================================
# TABLE 1: NotificationQueue
# Purpose: Queue for notifications awaiting delivery
# Features: Idempotency keys, retry tracking, persistence
# =========================================================================
class NotificationQueue(Base):
    """
    Queue entry for a notification
    
    Flow:
      1. Java backend sends HTTP POST with idempotency key
      2. Python INSERT to NOTIFICATION_QUEUE with status=PENDING
      3. APScheduler queries PENDING items every 30 seconds
      4. Sends to Firebase, updates status=SENT
    """
    __tablename__ = "NOTIFICATION_QUEUE"
    
    id = Column(Integer, primary_key=True)
    
    # Idempotency key: prevents duplicate notifications if Java retries
    idempotency_key = Column(String(255), unique=True, nullable=False, index=True)
    
    # Reference to user
    user_id = Column(Integer, nullable=False, index=True)
    
    # Full notification payload as JSON
    payload = Column(Text)
    
    # Status: PENDING, SENT, FAILED
    status = Column(String(20), default="PENDING", index=True, nullable=False)
    
    # Retry tracking
    retry_count = Column(Integer, default=0)
    
    # Firebase message ID when sent
    fcm_message_id = Column(String(255))
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Indexes for queue processing
    __table_args__ = (
        Index('IDX_QUEUE_STATUS', 'status', 'created_at'),
        Index('IDX_QUEUE_IDEMPOTENCY', 'idempotency_key'),
        Index('IDX_QUEUE_USER', 'user_id', 'status'),
    )

# =========================================================================
# TABLE 2: NotificationDeliveryAudit
# Purpose: Immutable audit trail of every delivery attempt
# Features: Append-only, never update/delete, HIPAA-compliant
# =========================================================================
class NotificationDeliveryAudit(Base):
    """
    Audit trail for notification delivery
    Never update or delete rows - append-only for compliance
    
    Each send attempt creates a new row:
      - SENT: Message sent to FCM
      - DELIVERED: Mobile app confirmed receipt
      - BOUNCED: Device token invalid
      - FAILED: FCM error
      - RETRY_SCHEDULED: Transient error, will retry
    """
    __tablename__ = "NOTIFICATION_DELIVERY_AUDIT"
    
    id = Column(Integer, primary_key=True)
    
    # Link to queue entry
    notification_queue_id = Column(Integer, nullable=False, index=True)
    
    # Firebase message ID
    fcm_message_id = Column(String(255), index=True)
    
    # Delivery status
    delivery_status = Column(String(20), index=True)
    
    # HTTP status code for debugging
    http_status_code = Column(Integer)
    
    # Response time in milliseconds
    response_time_ms = Column(Integer)
    
    # Error details
    error_message = Column(String(2000))
    
    # Which Python instance processed this (for debugging)
    server_instance = Column(String(50))
    
    # Timestamp of attempt
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    
    __table_args__ = (
        Index('IDX_AUDIT_STATUS', 'delivery_status', 'created_at'),
        Index('IDX_AUDIT_MESSAGE_ID', 'fcm_message_id'),
        Index('IDX_AUDIT_QUEUE_ID', 'notification_queue_id'),
    )

# =========================================================================
# TABLE 3: NotificationTemplate
# Purpose: Reusable templates with variable substitution
# Features: en/ar content, variable schemas
# =========================================================================
class NotificationTemplate(Base):
    """
    Reusable notification template
    
    Example:
      name: "appointment_confirmed"
      content_en: "New appointment with {{doctor_name}} at {{date}}"
      content_ar: "موعد جديد مع {{doctor_name}} في {{date}}"
      variables: ["doctor_name", "date"]
    
    During send, Jinja2 renders: "New appointment with Ahmed at 2026-04-05"
    """
    __tablename__ = "NOTIFICATION_TEMPLATES"
    
    id = Column(Integer, primary_key=True)
    
    # Template name (unique)
    name = Column(String(100), unique=True, nullable=False)
    
    # Category for grouping
    category = Column(String(50))
    
    # English template with {{variable}} placeholders
    content_en = Column(Text)
    
    # Arabic template
    content_ar = Column(Text)
    
    # JSON array of expected variables
    variables_schema = Column(Text)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    __table_args__ = (
        Index('IDX_TEMPLATE_NAME', 'name'),
        Index('IDX_TEMPLATE_CATEGORY', 'category'),
    )

# =========================================================================
# TABLE 4: NotificationPreferences
# Purpose: User notification settings
# Features: Language preference, quiet hours, opt-in flags
# =========================================================================
class NotificationPreferences(Base):
    """
    User notification preferences
    
    Tracks:
      - Language (en or ar)
      - Quiet hours (sleep time, no notifications)
      - Notification type preferences (appointment, reminder, etc.)
      - Retry settings
    """
    __tablename__ = "NOTIFICATION_PREFERENCES"
    
    id = Column(Integer, primary_key=True)
    
    # User ID (unique per user)
    user_id = Column(Integer, nullable=False, unique=True, index=True)
    
    # User type
    user_type = Column(String(20))
    
    # Language preference
    language = Column(String(10), default="en")
    
    # Quiet hours configuration
    quiet_hours_start = Column(Integer)  # 0-23
    quiet_hours_end = Column(Integer)    # 0-23
    quiet_hours_enabled = Column(Boolean, default=False)
    
    # Allow critical notifications during quiet hours?
    allow_critical_in_quiet_hours = Column(Boolean, default=False)
    
    # Notification type preferences
    push_notifications_enabled = Column(Boolean, default=True)
    appointment_confirmed_enabled = Column(Boolean, default=True)
    appointment_cancelled_enabled = Column(Boolean, default=True)
    appointment_reminder_enabled = Column(Boolean, default=True)
    booking_request_enabled = Column(Boolean, default=True)
    system_announcement_enabled = Column(Boolean, default=True)
    promotional_enabled = Column(Boolean, default=False)
    
    # Daily limit
    max_daily_notifications = Column(Integer, default=0)  # 0=unlimited
    
    # Retry settings
    enable_retry = Column(Boolean, default=True)
    retry_backoff_multiplier = Column(Integer, default=2)
    max_retries = Column(Integer, default=3)
    
    # Future features
    enable_fallback_email = Column(Boolean, default=False)
    
    # Timestamps
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    __table_args__ = (
        Index('IDX_PREF_USER_ID', 'user_id'),
        Index('IDX_PREF_LANGUAGE', 'language'),
    )

# =========================================================================
# TABLE 5: NotificationDeliveryAttempts
# Purpose: Track individual retry attempts
# Features: Full history of why failed, when will retry
# =========================================================================
class NotificationDeliveryAttempts(Base):
    """
    Detailed retry attempt tracking
    
    Useful for debugging why a notification failed:
      1st attempt: Timeout (will retry)
      2nd attempt: Service unavailable (will retry)
      3rd attempt: Invalid token (permanent, won't retry)
    """
    __tablename__ = "NOTIFICATION_DELIVERY_ATTEMPTS"
    
    id = Column(Integer, primary_key=True)
    
    # Link to queue entry
    notification_queue_id = Column(Integer, nullable=False, index=True)
    
    # Which attempt is this?
    attempt_number = Column(Integer)
    
    # Status: SUCCESS, FAILED, TRANSIENT_ERROR, PERMANENT_ERROR
    status = Column(String(20))
    
    # Error details
    error_message = Column(String(2000))
    error_code = Column(String(50))
    
    # Performance metrics
    response_time_ms = Column(Integer)
    
    # When will this be retried (if not success)?
    next_retry_at = Column(DateTime)
    
    # Timestamp of attempt
    attempted_at = Column(DateTime, default=datetime.utcnow)
    
    __table_args__ = (
        Index('IDX_ATTEMPTS_QUEUE', 'notification_queue_id'),
        Index('IDX_ATTEMPTS_STATUS', 'status'),
        Index('IDX_ATTEMPTS_TIME', 'attempted_at'),
    )

# =========================================================================
# TABLE 6: NotificationLogs
# Purpose: User-facing notification history
# Features: Link to delivery audit, read status, language tracking
# =========================================================================
class NotificationLog(Base):
    """
    User notification history/log
    
    What the user sees:
      - Unread notifications in app
      - Mark as read
      - View past notifications
    """
    __tablename__ = "NOTIFICATION_LOGS"
    
    id = Column(Integer, primary_key=True)
    
    # Recipient
    recipient_user_id = Column(Integer, nullable=False, index=True)
    recipient_user_type = Column(String(20))
    
    # Message
    title = Column(String(255))
    body = Column(String(1000))
    
    # Notification metadata
    notification_type = Column(String(50), index=True)
    
    # Link to related entity (which appointment, request, etc.)
    related_entity_id = Column(Integer)
    related_entity_type = Column(String(50))
    
    # Link to Firebase for tracking
    fcm_message_id = Column(String(255), index=True)
    
    # Delivery status
    delivery_status = Column(String(20))
    
    # Read status
    is_read = Column(Boolean, default=False)
    read_at = Column(DateTime)
    
    # Additional data (JSON)
    data_payload = Column(Text)
    
    # Language
    language = Column(String(10))
    
    # Timestamps
    sent_at = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    __table_args__ = (
        Index('IDX_LOG_RECIPIENT', 'recipient_user_id', 'created_at'),
        Index('IDX_LOG_TYPE', 'notification_type'),
        Index('IDX_LOG_ENTITY', 'related_entity_id', 'related_entity_type'),
        Index('IDX_LOG_UNREAD', 'recipient_user_id', 'is_read'),
    )
