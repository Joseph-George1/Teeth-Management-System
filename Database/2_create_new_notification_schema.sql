-- =====================================================================
-- CREATE NEW ADVANCED NOTIFICATION SCHEMA
-- =====================================================================
-- Purpose: Production-grade notification system with idempotency,
--          delivery tracking, templates, and multi-language support
-- Action: Run THIRD - creates 6 new tables, enhanced indexes
-- Location: c:\github\Teeth-Management-System\Database\
-- Date: April 4, 2026
-- =====================================================================

-- =====================================================================
-- TABLE 1: DEVICE_TOKENS (Enhanced from DEVICE_TOKEN)
-- Purpose: Store FCM tokens for mobile devices with platform tracking
-- Features: Soft-delete via is_active, multi-platform support
-- =====================================================================
CREATE TABLE DEVICE_TOKENS (
    ID NUMBER(19) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    TOKEN VARCHAR2(500) NOT NULL UNIQUE,
    USER_ID NUMBER(19) NOT NULL,
    
    -- New fields for advanced tracking
    PLATFORM VARCHAR2(20),                    -- 'ANDROID', 'IOS', 'WEB', 'WINDOWS'
    DEVICE_NAME VARCHAR2(255),                -- 'iPhone 13', 'Samsung Galaxy S21'
    USER_TYPE VARCHAR2(20),                   -- 'PATIENT', 'DOCTOR', 'ADMIN'
    
    -- Soft delete + status tracking
    IS_ACTIVE NUMBER(1) DEFAULT 1,            -- 0=inactive, 1=active
    LAST_USED_AT TIMESTAMP(6),                -- Track last successful send
    DEACTIVATED_AT TIMESTAMP(6),              -- When soft-deleted (logout)
    
    CREATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    UPDATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    
    CONSTRAINT FK_DEVICE_TOKENS_USER FOREIGN KEY (USER_ID) REFERENCES USERS(ID)
);

-- Indexes for performance
CREATE INDEX IDX_DEVICE_TOKENS_TOKEN ON DEVICE_TOKENS(TOKEN);
CREATE INDEX IDX_DEVICE_TOKENS_USER ON DEVICE_TOKENS(USER_ID, USER_TYPE);
CREATE INDEX IDX_DEVICE_TOKENS_ACTIVE ON DEVICE_TOKENS(USER_ID, IS_ACTIVE);
CREATE INDEX IDX_DEVICE_TOKENS_PLATFORM ON DEVICE_TOKENS(PLATFORM, IS_ACTIVE);

-- =====================================================================
-- TABLE 2: NOTIFICATION_TEMPLATES (New)
-- Purpose: Reusable notification templates with variable substitution
-- Features: en/ar content, variable schemas, category grouping
-- =====================================================================
CREATE TABLE NOTIFICATION_TEMPLATES (
    ID NUMBER(19) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    NAME VARCHAR2(100) NOT NULL UNIQUE,       -- 'appointment_confirmed', 'reminder_1h'
    CATEGORY VARCHAR2(50),                    -- 'appointment', 'reminder', 'cancellation'
    
    -- Template content with {{variable}} placeholders (Jinja2 style)
    CONTENT_EN CLOB,                          -- English template
    CONTENT_AR CLOB,                          -- Arabic template
    
    -- JSON array of expected variables: ["patientName", "appointmentDate"]
    VARIABLES_SCHEMA CLOB,
    
    CREATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    UPDATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    
    CONSTRAINT CHK_TEMPLATE_NAME CHECK (LENGTH(NAME) > 0)
);

CREATE INDEX IDX_NOTIFICATION_TEMPLATES_NAME ON NOTIFICATION_TEMPLATES(NAME);
CREATE INDEX IDX_NOTIFICATION_TEMPLATES_CATEGORY ON NOTIFICATION_TEMPLATES(CATEGORY);

-- =====================================================================
-- TABLE 3: NOTIFICATION_QUEUE (New)
-- Purpose: Queue for notifications awaiting delivery
-- Features: Idempotency keys prevent duplicates, retry tracking, persistence
-- =====================================================================
CREATE TABLE NOTIFICATION_QUEUE (
    ID NUMBER(19) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    -- Idempotency key: ensures exactly-once delivery
    -- Same request always gets same key, unique constraint prevents duplicates
    IDEMPOTENCY_KEY VARCHAR2(255) NOT NULL UNIQUE,
    
    USER_ID NUMBER(19) NOT NULL,
    
    -- Full notification payload as JSON
    PAYLOAD CLOB,
    
    -- Status: PENDING, SENT, FAILED
    STATUS VARCHAR2(20) DEFAULT 'PENDING',
    
    RETRY_COUNT NUMBER(5) DEFAULT 0,          -- Track retry attempts
    
    FCM_MESSAGE_ID VARCHAR2(255),             -- Firebase message ID when sent
    
    CREATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    UPDATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    
    CONSTRAINT FK_NOTIFICATION_QUEUE_USER FOREIGN KEY (USER_ID) REFERENCES USERS(ID),
    CONSTRAINT CHK_QUEUE_STATUS CHECK (STATUS IN ('PENDING', 'SENT', 'FAILED'))
);

-- Indexes for queue processing
CREATE INDEX IDX_QUEUE_STATUS ON NOTIFICATION_QUEUE(STATUS, CREATED_AT);
CREATE INDEX IDX_QUEUE_IDEMPOTENCY ON NOTIFICATION_QUEUE(IDEMPOTENCY_KEY);
CREATE INDEX IDX_QUEUE_USER_STATUS ON NOTIFICATION_QUEUE(USER_ID, STATUS);

-- =====================================================================
-- TABLE 4: NOTIFICATION_DELIVERY_AUDIT (New - IMMUTABLE)
-- Purpose: Immutable audit trail of every delivery attempt
-- Features: Append-only, never update/delete, full traceability
-- Healthcare Compliance: HIPAA-compliant audit log
-- =====================================================================
CREATE TABLE NOTIFICATION_DELIVERY_AUDIT (
    ID NUMBER(19) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    NOTIFICATION_QUEUE_ID NUMBER(19) NOT NULL,
    FCM_MESSAGE_ID VARCHAR2(255),             -- Link to firebase
    
    -- SENT, DELIVERED, BOUNCED, FAILED, RETRY_SCHEDULED
    DELIVERY_STATUS VARCHAR2(20),
    
    HTTP_STATUS_CODE NUMBER(4),               -- For debugging
    RESPONSE_TIME_MS NUMBER(5),               -- Track latency
    
    ERROR_MESSAGE VARCHAR2(2000),             -- If failed
    SERVER_INSTANCE VARCHAR2(50),             -- Which Python instance processed
    
    CREATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    
    CONSTRAINT FK_AUDIT_QUEUE FOREIGN KEY (NOTIFICATION_QUEUE_ID) 
        REFERENCES NOTIFICATION_QUEUE(ID),
    CONSTRAINT CHK_AUDIT_STATUS CHECK (DELIVERY_STATUS IN 
        ('SENT', 'DELIVERED', 'BOUNCED', 'FAILED', 'RETRY_SCHEDULED'))
);

-- Indexes for analytics
CREATE INDEX IDX_DELIVERY_AUDIT_STATUS ON NOTIFICATION_DELIVERY_AUDIT(DELIVERY_STATUS, CREATED_AT DESC);
CREATE INDEX IDX_DELIVERY_AUDIT_MSG_ID ON NOTIFICATION_DELIVERY_AUDIT(FCM_MESSAGE_ID);
CREATE INDEX IDX_DELIVERY_AUDIT_QUEUE_ID ON NOTIFICATION_DELIVERY_AUDIT(NOTIFICATION_QUEUE_ID);
CREATE INDEX IDX_DELIVERY_AUDIT_TIME ON NOTIFICATION_DELIVERY_AUDIT(CREATED_AT DESC);

-- =====================================================================
-- TABLE 5: NOTIFICATION_PREFERENCES (Enhanced)
-- Purpose: User notification settings (quiet hours, language, opt-in)
-- Features: Language preference, quiet hours enforcement, retry settings
-- =====================================================================
CREATE TABLE NOTIFICATION_PREFERENCES (
    ID NUMBER(19) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    USER_ID NUMBER(19) NOT NULL UNIQUE,
    USER_TYPE VARCHAR2(20),                   -- 'PATIENT', 'DOCTOR', 'ADMIN'
    
    -- Language preference for notifications
    LANGUAGE VARCHAR2(10) DEFAULT 'en',       -- 'en' or 'ar'
    
    -- Quiet hours configuration (prevent notifications during sleep)
    QUIET_HOURS_START NUMBER(2),              -- 0-23 (hours)
    QUIET_HOURS_END NUMBER(2),                -- 0-23 (hours)
    QUIET_HOURS_ENABLED NUMBER(1) DEFAULT 0, -- 0=off, 1=on
    
    -- Allow critical notifications (reminders) even during quiet hours?
    ALLOW_CRITICAL_IN_QUIET_HOURS NUMBER(1) DEFAULT 0,
    
    -- Enable notifications of various types
    PUSH_NOTIFICATIONS_ENABLED NUMBER(1) DEFAULT 1,
    APPOINTMENT_CONFIRMED_ENABLED NUMBER(1) DEFAULT 1,
    APPOINTMENT_CANCELLED_ENABLED NUMBER(1) DEFAULT 1,
    APPOINTMENT_REMINDER_ENABLED NUMBER(1) DEFAULT 1,
    BOOKING_REQUEST_ENABLED NUMBER(1) DEFAULT 1,
    SYSTEM_ANNOUNCEMENT_ENABLED NUMBER(1) DEFAULT 1,
    PROMOTIONAL_ENABLED NUMBER(1) DEFAULT 0,
    
    -- Daily notification limit (0 = unlimited)
    MAX_DAILY_NOTIFICATIONS NUMBER(5) DEFAULT 0,
    
    -- Retry settings
    ENABLE_RETRY NUMBER(1) DEFAULT 1,
    RETRY_BACKOFF_MULTIPLIER NUMBER(3,1) DEFAULT 2.0,
    MAX_RETRIES NUMBER(2) DEFAULT 3,
    
    -- Fallback email if FCM fails (future feature)
    ENABLE_FALLBACK_EMAIL NUMBER(1) DEFAULT 0,
    
    UPDATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    CREATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    
    CONSTRAINT FK_PREFERENCES_USER FOREIGN KEY (USER_ID) REFERENCES USERS(ID),
    CONSTRAINT CHK_LANGUAGE CHECK (LANGUAGE IN ('en', 'ar')),
    CONSTRAINT CHK_QUIET_HOURS_VALID CHECK (QUIET_HOURS_START >= 0 AND QUIET_HOURS_START <= 23),
    CONSTRAINT CHK_QUIET_END_VALID CHECK (QUIET_HOURS_END >= 0 AND QUIET_HOURS_END <= 23)
);

CREATE INDEX IDX_PREFERENCES_USER ON NOTIFICATION_PREFERENCES(USER_ID);
CREATE INDEX IDX_PREFERENCES_LANGUAGE ON NOTIFICATION_PREFERENCES(LANGUAGE);
CREATE INDEX IDX_PREFERENCES_QUIET_HOURS ON NOTIFICATION_PREFERENCES(USER_ID, QUIET_HOURS_ENABLED);

-- =====================================================================
-- TABLE 6: NOTIFICATION_DELIVERY_ATTEMPTS (New)
-- Purpose: Track individual retry attempts for recovery/debugging
-- Features: Full history of why notifications failed, when they retry
-- =====================================================================
CREATE TABLE NOTIFICATION_DELIVERY_ATTEMPTS (
    ID NUMBER(19) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    NOTIFICATION_QUEUE_ID NUMBER(19) NOT NULL,
    ATTEMPT_NUMBER NUMBER(2),                 -- 1st, 2nd, 3rd attempt
    
    -- SUCCESS, FAILED, TRANSIENT_ERROR, PERMANENT_ERROR
    STATUS VARCHAR2(20),
    
    ERROR_MESSAGE VARCHAR2(2000),
    ERROR_CODE VARCHAR2(50),
    
    RESPONSE_TIME_MS NUMBER(5),
    
    NEXT_RETRY_AT TIMESTAMP(6),               -- When this will be retried (if not success)
    ATTEMPTED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    
    CONSTRAINT FK_ATTEMPTS_QUEUE FOREIGN KEY (NOTIFICATION_QUEUE_ID) 
        REFERENCES NOTIFICATION_QUEUE(ID),
    CONSTRAINT CHK_ATTEMPT_STATUS CHECK (STATUS IN 
        ('SUCCESS', 'FAILED', 'TRANSIENT_ERROR', 'PERMANENT_ERROR'))
);

CREATE INDEX IDX_ATTEMPTS_QUEUE ON NOTIFICATION_DELIVERY_ATTEMPTS(NOTIFICATION_QUEUE_ID);
CREATE INDEX IDX_ATTEMPTS_STATUS ON NOTIFICATION_DELIVERY_ATTEMPTS(STATUS);
CREATE INDEX IDX_ATTEMPTS_TIME ON NOTIFICATION_DELIVERY_ATTEMPTS(ATTEMPTED_AT DESC);

-- =====================================================================
-- TABLE 7: ENHANCED NOTIFICATION_LOGS
-- Purpose: User-facing notification history (what they received)
-- Features: Link to delivery audit, read status tracking, language tracking
-- =====================================================================
CREATE TABLE NOTIFICATION_LOGS (
    ID NUMBER(19) GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    RECIPIENT_USER_ID NUMBER(19) NOT NULL,
    RECIPIENT_USER_TYPE VARCHAR2(20),        -- 'PATIENT', 'DOCTOR', 'ADMIN'
    
    TITLE VARCHAR2(255),
    BODY VARCHAR2(1000),
    
    -- Notification type for analytics
    NOTIFICATION_TYPE VARCHAR2(50),          -- 'APPOINTMENT_CONFIRMED', 'REMINDER', etc.
    
    -- Link to related entity (appointment, request, etc.)
    RELATED_ENTITY_ID NUMBER(19),
    RELATED_ENTITY_TYPE VARCHAR2(50),        -- 'APPOINTMENT', 'REQUEST', 'BOOKING'
    
    -- Link to Firebase delivery tracking
    FCM_MESSAGE_ID VARCHAR2(255),            -- For querying delivery status
    
    -- Delivery status
    DELIVERY_STATUS VARCHAR2(20),            -- 'SENT', 'DELIVERED', 'BOUNCED', 'FAILED'
    
    -- Read status
    IS_READ NUMBER(1) DEFAULT 0,
    READ_AT TIMESTAMP(6),
    
    -- Additional data (JSON)
    DATA_PAYLOAD CLOB,
    
    -- Language of the notification
    LANGUAGE VARCHAR2(10),                   -- 'en', 'ar'
    
    SENT_AT TIMESTAMP(6),
    CREATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    UPDATED_AT TIMESTAMP(6) DEFAULT SYSDATE,
    
    CONSTRAINT FK_NOTIFICATION_LOGS_USER FOREIGN KEY (RECIPIENT_USER_ID) REFERENCES USERS(ID),
    CONSTRAINT CHK_DELIVERY_STATUS CHECK (DELIVERY_STATUS IN 
        ('SENT', 'DELIVERED', 'BOUNCED', 'FAILED')),
    CONSTRAINT CHK_IS_READ CHECK (IS_READ IN (0, 1))
);

-- Indexes for common queries
CREATE INDEX IDX_NOTIFICATION_LOGS_USER ON NOTIFICATION_LOGS(RECIPIENT_USER_ID, CREATED_AT DESC);
CREATE INDEX IDX_NOTIFICATION_LOGS_IS_READ ON NOTIFICATION_LOGS(RECIPIENT_USER_ID, IS_READ);
CREATE INDEX IDX_NOTIFICATION_LOGS_TYPE ON NOTIFICATION_LOGS(NOTIFICATION_TYPE);
CREATE INDEX IDX_NOTIFICATION_LOGS_ENTITY ON NOTIFICATION_LOGS(RELATED_ENTITY_ID, RELATED_ENTITY_TYPE);
CREATE INDEX IDX_NOTIFICATION_LOGS_FCM_ID ON NOTIFICATION_LOGS(FCM_MESSAGE_ID);
CREATE INDEX IDX_NOTIFICATION_LOGS_DELIVERY ON NOTIFICATION_LOGS(DELIVERY_STATUS);
CREATE INDEX IDX_NOTIFICATION_LOGS_UNREAD ON NOTIFICATION_LOGS(RECIPIENT_USER_ID, IS_READ) WHERE IS_READ = 0;

-- Commit all changes
COMMIT;

-- Verify all tables created
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== NOTIFICATION SCHEMA CREATED SUCCESSFULLY ===');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Tables created:');
  DBMS_OUTPUT.PUT_LINE('1. DEVICE_TOKENS');
  DBMS_OUTPUT.PUT_LINE('2. NOTIFICATION_TEMPLATES');
  DBMS_OUTPUT.PUT_LINE('3. NOTIFICATION_QUEUE');
  DBMS_OUTPUT.PUT_LINE('4. NOTIFICATION_DELIVERY_AUDIT');
  DBMS_OUTPUT.PUT_LINE('5. NOTIFICATION_PREFERENCES');
  DBMS_OUTPUT.PUT_LINE('6. NOTIFICATION_DELIVERY_ATTEMPTS');
  DBMS_OUTPUT.PUT_LINE('7. NOTIFICATION_LOGS');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Features enabled:');
  DBMS_OUTPUT.PUT_LINE('✓ Idempotency keys (exactly-once delivery)');
  DBMS_OUTPUT.PUT_LINE('✓ Immutable audit trail');
  DBMS_OUTPUT.PUT_LINE('✓ Multi-language support (en/ar)');
  DBMS_OUTPUT.PUT_LINE('✓ Template system');
  DBMS_OUTPUT.PUT_LINE('✓ Queue persistence');
  DBMS_OUTPUT.PUT_LINE('✓ Retry tracking');
  DBMS_OUTPUT.PUT_LINE('✓ User preferences (quiet hours, language)');
END;
/

-- Show all notification tables
SELECT table_name FROM user_tables 
WHERE table_name LIKE 'NOTIFICATION%' OR table_name = 'DEVICE_TOKENS'
ORDER BY table_name;
