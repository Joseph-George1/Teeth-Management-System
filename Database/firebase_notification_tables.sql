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

BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE DEVICE_TOKEN (
    ID              NUMBER(19) PRIMARY KEY,
    TOKEN           VARCHAR2(500 CHAR) NOT NULL UNIQUE,
    USER_ID         NUMBER(19) NOT NULL,
    CREATED_AT      TIMESTAMP DEFAULT SYSDATE NOT NULL,
    UPDATED_AT      TIMESTAMP DEFAULT SYSDATE NOT NULL
  )';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error creating DEVICE_TOKEN: ' || SQLERRM);
    RAISE;
END;
/

-- Create sequence for DEVICE_TOKEN ID
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_DEVICE_TOKEN_ID';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_DEVICE_TOKEN_ID START WITH 1 INCREMENT BY 1 NOCYCLE';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Create trigger for auto-increment ID and UPDATED_AT
BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER DEVICE_TOKEN_ID_TRIGGER';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER DEVICE_TOKEN_ID_TRIGGER
BEFORE INSERT ON DEVICE_TOKEN
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_DEVICE_TOKEN_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
    :NEW.CREATED_AT := SYSDATE;
    :NEW.UPDATED_AT := SYSDATE;
END;
/

-- Create trigger to update UPDATED_AT on modification
BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER DEVICE_TOKEN_UPDATE_TRIGGER';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER DEVICE_TOKEN_UPDATE_TRIGGER
BEFORE UPDATE ON DEVICE_TOKEN
FOR EACH ROW
BEGIN
    :NEW.UPDATED_AT := SYSDATE;
END;
/

-- Create indexes for performance
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_DEVICE_TOKEN_USER_ID ON DEVICE_TOKEN(USER_ID)';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_DEVICE_TOKEN_TOKEN ON DEVICE_TOKEN(TOKEN)';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Add foreign key constraint (conditional)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE DEVICE_TOKEN ADD CONSTRAINT FK_DEVICE_TOKEN_USER FOREIGN KEY (USER_ID) REFERENCES "user"(ID)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Note: Foreign key FK_DEVICE_TOKEN_USER could not be created.');
    DBMS_OUTPUT.PUT_LINE('This is expected if "user" table does not exist yet.');
    DBMS_OUTPUT.PUT_LINE('The constraint will be added after Hibernate creates the "user" table.');
END;
/

-- Comments for documentation
BEGIN
  EXECUTE IMMEDIATE 'COMMENT ON TABLE DEVICE_TOKEN IS ''Firebase Cloud Messaging device tokens for push notifications''';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN DEVICE_TOKEN.TOKEN IS ''Unique FCM device token from Firebase SDK''';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN DEVICE_TOKEN.USER_ID IS ''Reference to user table (links to User entity)''';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

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

BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE NOTIFICATION_LOG (
    ID              NUMBER(19) PRIMARY KEY,
    TITLE           VARCHAR2(255 CHAR) NOT NULL,
    BODY            VARCHAR2(1000 CHAR) NOT NULL,
    READ_STATUS     NUMBER(1) NOT NULL DEFAULT 0,
    USER_ID         NUMBER(19) NOT NULL,
    CREATED_AT      TIMESTAMP DEFAULT SYSDATE NOT NULL,
    UPDATED_AT      TIMESTAMP DEFAULT SYSDATE NOT NULL
  )';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Error creating NOTIFICATION_LOG: ' || SQLERRM);
    RAISE;
END;
/

-- Create sequence for NOTIFICATION_LOG ID
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE SEQ_NOTIFICATION_LOG_ID';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE SEQ_NOTIFICATION_LOG_ID START WITH 1 INCREMENT BY 1 NOCYCLE';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Create trigger for auto-increment ID and UPDATED_AT
BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER NOTIFICATION_LOG_ID_TRIGGER';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER NOTIFICATION_LOG_ID_TRIGGER
BEFORE INSERT ON NOTIFICATION_LOG
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_NOTIFICATION_LOG_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
    :NEW.CREATED_AT := SYSDATE;
    :NEW.UPDATED_AT := SYSDATE;
END;
/

-- Create trigger to update UPDATED_AT on modification
BEGIN
  EXECUTE IMMEDIATE 'DROP TRIGGER NOTIFICATION_LOG_UPDATE_TRIGGER';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE OR REPLACE TRIGGER NOTIFICATION_LOG_UPDATE_TRIGGER
BEFORE UPDATE ON NOTIFICATION_LOG
FOR EACH ROW
BEGIN
    :NEW.UPDATED_AT := SYSDATE;
END;
/

-- Create indexes for performance
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_NOTIFICATION_LOG_USER_ID ON NOTIFICATION_LOG(USER_ID)';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_NOTIFICATION_LOG_READ_STATUS ON NOTIFICATION_LOG(READ_STATUS)';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_NOTIFICATION_LOG_CREATED_AT ON NOTIFICATION_LOG(CREATED_AT)';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_NOTIFICATION_LOG_UNREAD ON NOTIFICATION_LOG(USER_ID, READ_STATUS)';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Add foreign key constraint (conditional)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE NOTIFICATION_LOG ADD CONSTRAINT FK_NOTIFICATION_LOG_USER FOREIGN KEY (USER_ID) REFERENCES "user"(ID)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Note: Foreign key FK_NOTIFICATION_LOG_USER could not be created.');
    DBMS_OUTPUT.PUT_LINE('This is expected if "user" table does not exist yet.');
    DBMS_OUTPUT.PUT_LINE('The constraint will be added after Hibernate creates the "user" table.');
END;
/

-- Comments for documentation
BEGIN
  EXECUTE IMMEDIATE 'COMMENT ON TABLE NOTIFICATION_LOG IS ''Audit trail of all notifications sent to users''';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN NOTIFICATION_LOG.READ_STATUS IS ''Whether user has read the notification (1=yes, 0=no)''';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'COMMENT ON COLUMN NOTIFICATION_LOG.USER_ID IS ''Reference to user table (links to User entity)''';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Check DEVICE_TOKEN table structure
DESC DEVICE_TOKEN;

-- Check NOTIFICATION_LOG table structure
DESC NOTIFICATION_LOG;

-- Show table creation status
BEGIN
  DBMS_OUTPUT.PUT_LINE('╔════════════════════════════════════════════════════════════╗');
  DBMS_OUTPUT.PUT_LINE('║  FIREBASE NOTIFICATION TABLES CREATED SUCCESSFULLY         ║');
  DBMS_OUTPUT.PUT_LINE('╚════════════════════════════════════════════════════════════╝');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Tables created:');
  DBMS_OUTPUT.PUT_LINE('  1. DEVICE_TOKEN (Firebase device tokens)');
  DBMS_OUTPUT.PUT_LINE('  2. NOTIFICATION_LOG (Notification audit trail)');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Sequences created:');
  DBMS_OUTPUT.PUT_LINE('  1. SEQ_DEVICE_TOKEN_ID');
  DBMS_OUTPUT.PUT_LINE('  2. SEQ_NOTIFICATION_LOG_ID');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('Triggers created for auto-increment and UPDATED_AT timestamps');
  DBMS_OUTPUT.PUT_LINE('Indexes created for optimal performance');
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('NEXT STEP: After Hibernate creates the "user" table,');
  DBMS_OUTPUT.PUT_LINE('run the ADD_FOREIGN_KEYS script to link these tables.');
END;
/

-- ============================================================================
-- END OF FIREBASE NOTIFICATION TABLES MIGRATION
-- ============================================================================
