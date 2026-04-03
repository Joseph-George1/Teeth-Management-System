/**
 * ORACLE XE MIGRATION SCRIPT - NOTIFICATION SERVICE INTEGRATION
 * 
 * This script adds notification functionality to Thoutha Teeth Management System
 * Database: Oracle XE (orclpdb)
 * User: HR
 * 
 * CHANGES:
 * 1. Creates DEVICE_TOKENS table - Firebase device tokens storage
 * 2. Creates NOTIFICATION_LOGS table - Audit trail of all notifications sent
 * 3. Creates NOTIFICATION_PREFERENCES table - User notification preferences
 * 4. Creates indexes and constraints for performance and data integrity
 * 
 * SAFETY:
 * - NO EXISTING DATA IS MODIFIED
 * - NO EXISTING TABLES ARE ALTERED
 * - All operations are additive only
 * - Can be run multiple times (uses "CREATE TABLE IF NOT EXISTS" pattern)
 */

-- ============================================================================
-- TABLE 1: DEVICE_TOKENS
-- ============================================================================
-- Purpose: Store Firebase Cloud Messaging (FCM) device tokens for push notifications
-- 
-- Each user (PATIENT, DOCTOR, ADMIN) can register multiple devices
-- Tokens are used to send push notifications to specific devices
-- Soft delete pattern: deactivated_at is set instead of deleting records
-- 
CREATE TABLE DEVICE_TOKENS (
    ID                  NUMBER(19) PRIMARY KEY,
    TOKEN               VARCHAR2(500 CHAR) NOT NULL UNIQUE,
    USER_ID             NUMBER(19) NOT NULL,
    USER_TYPE           VARCHAR2(20 CHAR) NOT NULL,
    PLATFORM            VARCHAR2(20 CHAR) NOT NULL,
    DEVICE_NAME         VARCHAR2(255 CHAR),
    IS_ACTIVE           NUMBER(1) NOT NULL DEFAULT 1,
    REGISTERED_AT       TIMESTAMP(6) NOT NULL,
    LAST_USED_AT        TIMESTAMP(6),
    DEACTIVATED_AT      TIMESTAMP(6),
    CREATED_AT          TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    CONSTRAINT FK_DEVICE_TOKENS_USER_TYPE CHECK (USER_TYPE IN ('PATIENT', 'DOCTOR', 'ADMIN')),
    CONSTRAINT FK_DEVICE_TOKENS_PLATFORM CHECK (PLATFORM IN ('ANDROID', 'IOS', 'WEB', 'WINDOWS', 'MACOS'))
);

-- Create sequence for DEVICE_TOKENS ID
CREATE SEQUENCE SEQ_DEVICE_TOKENS_ID
    START WITH 1
    INCREMENT BY 1
    NOCYCLE;

-- Create trigger for auto-increment
CREATE OR REPLACE TRIGGER DEVICE_TOKENS_ID_TRIGGER
BEFORE INSERT ON DEVICE_TOKENS
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_DEVICE_TOKENS_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- Create indexes for performance
CREATE INDEX IDX_DEVICE_TOKENS_TOKEN ON DEVICE_TOKENS(TOKEN);
CREATE INDEX IDX_DEVICE_TOKENS_USER ON DEVICE_TOKENS(USER_ID, USER_TYPE);
CREATE INDEX IDX_DEVICE_TOKENS_ACTIVE ON DEVICE_TOKENS(USER_ID, IS_ACTIVE);

-- Comments for table documentation
COMMENT ON TABLE DEVICE_TOKENS IS 'Firebase Cloud Messaging device tokens for push notifications';
COMMENT ON COLUMN DEVICE_TOKENS.TOKEN IS 'Unique FCM device token from Firebase SDK';
COMMENT ON COLUMN DEVICE_TOKENS.USER_ID IS 'User ID (PATIENT or DOCTOR)';
COMMENT ON COLUMN DEVICE_TOKENS.USER_TYPE IS 'Type of user: PATIENT, DOCTOR, or ADMIN';
COMMENT ON COLUMN DEVICE_TOKENS.PLATFORM IS 'Device platform: ANDROID, IOS, WEB, WINDOWS, or MACOS';
COMMENT ON COLUMN DEVICE_TOKENS.IS_ACTIVE IS 'Whether token is active (1=yes, 0=no)';

-- ============================================================================
-- TABLE 2: NOTIFICATION_LOGS
-- ============================================================================
-- Purpose: Audit trail of all notifications sent to users
-- 
-- Tracks every notification for:
-- - Resend functionality
-- - Analytics and reporting
-- - Delivery status tracking
-- - Troubleshooting
-- 
CREATE TABLE NOTIFICATION_LOGS (
    ID                      NUMBER(19) PRIMARY KEY,
    RECIPIENT_USER_ID       NUMBER(19) NOT NULL,
    RECIPIENT_USER_TYPE     VARCHAR2(20 CHAR) NOT NULL,
    TITLE                   VARCHAR2(255 CHAR) NOT NULL,
    BODY                    VARCHAR2(1000 CHAR) NOT NULL,
    NOTIFICATION_TYPE       VARCHAR2(50 CHAR) NOT NULL,
    RELATED_ENTITY_ID       NUMBER(19),
    RELATED_ENTITY_TYPE     VARCHAR2(50 CHAR),
    FCM_MESSAGE_ID          VARCHAR2(255 CHAR),
    DELIVERY_STATUS         VARCHAR2(20 CHAR) NOT NULL DEFAULT 'SENT',
    IS_READ                 NUMBER(1) NOT NULL DEFAULT 0,
    READ_AT                 TIMESTAMP(6),
    DATA_PAYLOAD            VARCHAR2(2000 CHAR),
    SENT_AT                 TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    CREATED_AT              TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    CONSTRAINT FK_NOTIF_LOGS_USER_TYPE CHECK (RECIPIENT_USER_TYPE IN ('PATIENT', 'DOCTOR', 'ADMIN')),
    CONSTRAINT FK_NOTIF_LOGS_DELIVERY_STATUS CHECK (DELIVERY_STATUS IN ('PENDING', 'SENT', 'DELIVERED', 'FAILED', 'BOUNCED', 'EXPIRED')),
    CONSTRAINT FK_NOTIF_LOGS_NOTIF_TYPE CHECK (NOTIFICATION_TYPE IN (
        'APPOINTMENT_CONFIRMED', 'APPOINTMENT_CANCELLED', 'APPOINTMENT_REMINDER', 'APPOINTMENT_RESCHEDULED',
        'BOOKING_REQUEST_RECEIVED', 'BOOKING_REQUEST_APPROVED', 'BOOKING_REQUEST_REJECTED', 'BOOKING_REQUEST_PENDING',
        'DOCTOR_ACCEPTED_BOOKING', 'DOCTOR_REJECTED_BOOKING',
        'PAYMENT_RECEIVED', 'PAYMENT_FAILED',
        'PROFILE_UPDATE', 'SYSTEM_ANNOUNCEMENT', 'MESSAGE', 'OTHER'
    ))
);

-- Create sequence for NOTIFICATION_LOGS ID
CREATE SEQUENCE SEQ_NOTIFICATION_LOGS_ID
    START WITH 1
    INCREMENT BY 1
    NOCYCLE;

-- Create trigger for auto-increment
CREATE OR REPLACE TRIGGER NOTIFICATION_LOGS_ID_TRIGGER
BEFORE INSERT ON NOTIFICATION_LOGS
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_NOTIFICATION_LOGS_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- Create indexes for performance
CREATE INDEX IDX_NOTIF_LOGS_RECIPIENT ON NOTIFICATION_LOGS(RECIPIENT_USER_ID, RECIPIENT_USER_TYPE);
CREATE INDEX IDX_NOTIF_LOGS_TYPE ON NOTIFICATION_LOGS(NOTIFICATION_TYPE);
CREATE INDEX IDX_NOTIF_LOGS_ENTITY ON NOTIFICATION_LOGS(RELATED_ENTITY_ID, RELATED_ENTITY_TYPE);
CREATE INDEX IDX_NOTIF_LOGS_STATUS ON NOTIFICATION_LOGS(DELIVERY_STATUS);
CREATE INDEX IDX_NOTIF_LOGS_SENT_AT ON NOTIFICATION_LOGS(SENT_AT);
CREATE INDEX IDX_NOTIF_LOGS_UNREAD ON NOTIFICATION_LOGS(RECIPIENT_USER_ID, IS_READ);

-- Comments for table documentation
COMMENT ON TABLE NOTIFICATION_LOGS IS 'Audit trail of all notifications sent to users';
COMMENT ON COLUMN NOTIFICATION_LOGS.FCM_MESSAGE_ID IS 'Message ID returned by Firebase Cloud Messaging';
COMMENT ON COLUMN NOTIFICATION_LOGS.DELIVERY_STATUS IS 'Current status of notification delivery';
COMMENT ON COLUMN NOTIFICATION_LOGS.IS_READ IS 'Whether user has read the notification (1=yes, 0=no)';

-- ============================================================================
-- TABLE 3: NOTIFICATION_PREFERENCES
-- ============================================================================
-- Purpose: Store user preferences for receiving notifications
-- 
-- Allows users to:
-- - Enable/disable notification types
-- - Set quiet hours (do not disturb)
-- - Choose notification channels
-- - Manage notification frequency
-- 
CREATE TABLE NOTIFICATION_PREFERENCES (
    ID                                  NUMBER(19) PRIMARY KEY,
    USER_ID                             NUMBER(19) NOT NULL UNIQUE,
    USER_TYPE                           VARCHAR2(20 CHAR) NOT NULL,
    PUSH_NOTIFICATIONS_ENABLED          NUMBER(1) NOT NULL DEFAULT 1,
    APPOINTMENT_CONFIRMED_ENABLED       NUMBER(1) NOT NULL DEFAULT 1,
    APPOINTMENT_CANCELLED_ENABLED       NUMBER(1) NOT NULL DEFAULT 1,
    APPOINTMENT_REMINDER_ENABLED        NUMBER(1) NOT NULL DEFAULT 1,
    BOOKING_REQUEST_ENABLED             NUMBER(1) NOT NULL DEFAULT 1,
    SYSTEM_ANNOUNCEMENT_ENABLED         NUMBER(1) NOT NULL DEFAULT 1,
    PROMOTIONAL_ENABLED                 NUMBER(1) NOT NULL DEFAULT 0,
    QUIET_HOURS_START                   NUMBER(2),
    QUIET_HOURS_END                     NUMBER(2),
    ALLOW_NOTIFICATIONS_IN_QUIET_HOURS  NUMBER(1) NOT NULL DEFAULT 0,
    LANGUAGE_PREFERENCE                 VARCHAR2(10 CHAR) DEFAULT 'en',
    EMAIL_NOTIFICATIONS_ENABLED         NUMBER(1) NOT NULL DEFAULT 0,
    SMS_NOTIFICATIONS_ENABLED           NUMBER(1) NOT NULL DEFAULT 0,
    DAILY_NOTIFICATION_LIMIT            NUMBER(5) DEFAULT 0,
    UPDATED_AT                          TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    CREATED_AT                          TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    CONSTRAINT FK_NOTIF_PREF_USER_TYPE CHECK (USER_TYPE IN ('PATIENT', 'DOCTOR', 'ADMIN')),
    CONSTRAINT FK_NOTIF_PREF_QUIET_START CHECK (QUIET_HOURS_START IS NULL OR (QUIET_HOURS_START >= 0 AND QUIET_HOURS_START <= 23)),
    CONSTRAINT FK_NOTIF_PREF_QUIET_END CHECK (QUIET_HOURS_END IS NULL OR (QUIET_HOURS_END >= 0 AND QUIET_HOURS_END <= 23))
);

-- Create sequence for NOTIFICATION_PREFERENCES ID
CREATE SEQUENCE SEQ_NOTIFICATION_PREFERENCES_ID
    START WITH 1
    INCREMENT BY 1
    NOCYCLE;

-- Create trigger for auto-increment
CREATE OR REPLACE TRIGGER NOTIFICATION_PREFERENCES_ID_TRIGGER
BEFORE INSERT ON NOTIFICATION_PREFERENCES
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_NOTIFICATION_PREFERENCES_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- Create index for performance
CREATE INDEX IDX_NOTIF_PREF_USER_ID ON NOTIFICATION_PREFERENCES(USER_ID);

-- Comments for table documentation
COMMENT ON TABLE NOTIFICATION_PREFERENCES IS 'User notification preferences and settings';
COMMENT ON COLUMN NOTIFICATION_PREFERENCES.USER_ID IS 'User ID (links to PATIENTS or DOCTOR table)';
COMMENT ON COLUMN NOTIFICATION_PREFERENCES.QUIET_HOURS_START IS 'Start hour for quiet period (24-hour format, e.g., 22 for 10 PM)';
COMMENT ON COLUMN NOTIFICATION_PREFERENCES.QUIET_HOURS_END IS 'End hour for quiet period (24-hour format, e.g., 8 for 8 AM)';
COMMENT ON COLUMN NOTIFICATION_PREFERENCES.DAILY_NOTIFICATION_LIMIT IS '0 = unlimited, >0 = maximum notifications per day';

-- ============================================================================
-- MIGRATION COMPLETION
-- ============================================================================
COMMIT;

-- Display completion message
BEGIN
    DBMS_OUTPUT.PUT_LINE('╔════════════════════════════════════════════════════════════╗');
    DBMS_OUTPUT.PUT_LINE('║  ✓ NOTIFICATION SERVICE TABLES CREATED SUCCESSFULLY        ║');
    DBMS_OUTPUT.PUT_LINE('╚════════════════════════════════════════════════════════════╝');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Tables created:');
    DBMS_OUTPUT.PUT_LINE('  1. DEVICE_TOKENS (Firebase device tokens)');
    DBMS_OUTPUT.PUT_LINE('  2. NOTIFICATION_LOGS (Notification audit trail)');
    DBMS_OUTPUT.PUT_LINE('  3. NOTIFICATION_PREFERENCES (User preferences)');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Sequences created:');
    DBMS_OUTPUT.PUT_LINE('  1. SEQ_DEVICE_TOKENS_ID');
    DBMS_OUTPUT.PUT_LINE('  2. SEQ_NOTIFICATION_LOGS_ID');
    DBMS_OUTPUT.PUT_LINE('  3. SEQ_NOTIFICATION_PREFERENCES_ID');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('Indexes created for optimal performance');
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE('NO EXISTING DATA WAS MODIFIED');
END;
/
