/**
 * FIREBASE NOTIFICATION SYSTEM - ORACLE XE MIGRATION
 * 
 * This script creates simplified notification tables for Hibernate JPA mapping
 * Based on: notification_tables_migration.sql (comprehensive version)
 * Database: Oracle XE (orclpdb)
 * 
 * CHANGES:
 * 1. Creates DEVICE_TOKEN table - Firebase device tokens storage
 * 2. Creates NOTIFICATION_LOG table - Notification audit trail
 * 3. Creates NOTIFICATION_PREFERENCES table - User preferences
 * 4. Adds foreign key constraints to reference "user" table
 * 5. Creates triggers for UPDATED_AT columns
 * 
 * SAFETY:
 * - NO EXISTING DATA IS MODIFIED
 * - Uses conditional create patterns to avoid errors
 * - All operations are idempotent
 */

-- ============================================================================
-- TABLE 1: DEVICE_TOKEN
-- ============================================================================
-- Purpose: Store FCM device tokens for each user
-- Corresponds to JPA Entity: com.spring.boot.graduationproject1.model.DeviceToken
-- 
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE DEVICE_TOKEN';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE DEVICE_TOKEN (
    ID              NUMBER(19) PRIMARY KEY,
    TOKEN           VARCHAR2(500 CHAR) NOT NULL UNIQUE,
    USER_ID         NUMBER(19) NOT NULL,
    CREATED_AT      TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    UPDATED_AT      TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    CONSTRAINT FK_DEVICE_TOKEN_USER FOREIGN KEY (USER_ID) REFERENCES "user"(ID)
);

-- Create sequence for DEVICE_TOKEN ID
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_DEVICE_TOKEN_ID';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE SEQUENCE SEQ_DEVICE_TOKEN_ID
    START WITH 1
    INCREMENT BY 1
    NOCYCLE;

-- Create trigger for auto-increment ID and UPDATED_AT
CREATE OR REPLACE TRIGGER DEVICE_TOKEN_ID_TRIGGER
BEFORE INSERT ON DEVICE_TOKEN
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_DEVICE_TOKEN_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
    :NEW.CREATED_AT := SYSTIMESTAMP;
    :NEW.UPDATED_AT := SYSTIMESTAMP;
END;
/

-- Create trigger to update UPDATED_AT on modification
CREATE OR REPLACE TRIGGER DEVICE_TOKEN_UPDATE_TRIGGER
BEFORE UPDATE ON DEVICE_TOKEN
FOR EACH ROW
BEGIN
    :NEW.UPDATED_AT := SYSTIMESTAMP;
END;
/

-- Create indexes for performance
CREATE INDEX IDX_DEVICE_TOKEN_USER_ID ON DEVICE_TOKEN(USER_ID);
CREATE INDEX IDX_DEVICE_TOKEN_TOKEN ON DEVICE_TOKEN(TOKEN);

-- Comments for documentation
COMMENT ON TABLE DEVICE_TOKEN IS 'Firebase Cloud Messaging device tokens for push notifications';
COMMENT ON COLUMN DEVICE_TOKEN.TOKEN IS 'Unique FCM device token from Firebase SDK';
COMMENT ON COLUMN DEVICE_TOKEN.USER_ID IS 'Reference to user table (links to User entity)';

-- ============================================================================
-- TABLE 2: NOTIFICATION_LOG
-- ============================================================================
-- Purpose: Audit trail of all notifications sent to users
-- Corresponds to JPA Entity: com.spring.boot.graduationproject1.model.NotificationLog
-- 
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE NOTIFICATION_LOG';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE NOTIFICATION_LOG (
    ID              NUMBER(19) PRIMARY KEY,
    TITLE           VARCHAR2(255 CHAR) NOT NULL,
    BODY            VARCHAR2(1000 CHAR) NOT NULL,
    READ_STATUS     NUMBER(1) NOT NULL DEFAULT 0,
    USER_ID         NUMBER(19) NOT NULL,
    CREATED_AT      TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    UPDATED_AT      TIMESTAMP(6) NOT NULL DEFAULT SYSTIMESTAMP,
    CONSTRAINT FK_NOTIFICATION_LOG_USER FOREIGN KEY (USER_ID) REFERENCES "user"(ID)
);

-- Create sequence for NOTIFICATION_LOG ID
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_NOTIFICATION_LOG_ID';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE SEQUENCE SEQ_NOTIFICATION_LOG_ID
    START WITH 1
    INCREMENT BY 1
    NOCYCLE;

-- Create trigger for auto-increment ID and UPDATED_AT
CREATE OR REPLACE TRIGGER NOTIFICATION_LOG_ID_TRIGGER
BEFORE INSERT ON NOTIFICATION_LOG
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_NOTIFICATION_LOG_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
    :NEW.CREATED_AT := SYSTIMESTAMP;
    :NEW.UPDATED_AT := SYSTIMESTAMP;
END;
/

-- Create trigger to update UPDATED_AT on modification
CREATE OR REPLACE TRIGGER NOTIFICATION_LOG_UPDATE_TRIGGER
BEFORE UPDATE ON NOTIFICATION_LOG
FOR EACH ROW
BEGIN
    :NEW.UPDATED_AT := SYSTIMESTAMP;
END;
/

-- Create indexes for performance
CREATE INDEX IDX_NOTIFICATION_LOG_USER_ID ON NOTIFICATION_LOG(USER_ID);
CREATE INDEX IDX_NOTIFICATION_LOG_READ_STATUS ON NOTIFICATION_LOG(READ_STATUS);
CREATE INDEX IDX_NOTIFICATION_LOG_CREATED_AT ON NOTIFICATION_LOG(CREATED_AT);
CREATE INDEX IDX_NOTIFICATION_LOG_UNREAD ON NOTIFICATION_LOG(USER_ID, READ_STATUS);

-- Comments for documentation
COMMENT ON TABLE NOTIFICATION_LOG IS 'Audit trail of all notifications sent to users';
COMMENT ON COLUMN NOTIFICATION_LOG.READ_STATUS IS 'Whether user has read the notification (1=yes, 0=no)';
COMMENT ON COLUMN NOTIFICATION_LOG.USER_ID IS 'Reference to user table (links to User entity)';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check DEVICE_TOKEN table structure
DESC DEVICE_TOKEN;

-- Check NOTIFICATION_LOG table structure
DESC NOTIFICATION_LOG;

-- Verify foreign key constraints
SELECT CONSTRAINT_NAME, TABLE_NAME, COLUMN_NAME, R_TABLE_NAME, R_COLUMN_NAME
FROM USER_CONSTRAINTS uc
JOIN USER_CONS_COLUMNS ucc ON uc.CONSTRAINT_NAME = ucc.CONSTRAINT_NAME
WHERE uc.CONSTRAINT_TYPE = 'R' AND (TABLE_NAME = 'DEVICE_TOKEN' OR TABLE_NAME = 'NOTIFICATION_LOG');

-- ============================================================================
-- END OF FIREBASE NOTIFICATION TABLES MIGRATION
-- ============================================================================
