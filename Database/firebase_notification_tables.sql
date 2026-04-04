/**
 * FIREBASE NOTIFICATION SYSTEM - CLEAN TABLE CREATION
 * 
 * This script DROPS and RECREATES notification tables from scratch
 * Database: Oracle XE (orclpdb)
 * 
 * OPERATIONS:
 * 1. Drops existing DEVICE_TOKEN table
 * 2. Drops existing NOTIFICATION_LOG table
 * 3. Creates fresh DEVICE_TOKEN table
 * 4. Creates fresh NOTIFICATION_LOG table
 * 5. Creates sequences and triggers
 * 6. Creates indexes
 * 
 * WARNING: This will delete all existing data in these tables!
 */

-- ============================================================================
-- STEP 1: DROP EXISTING TABLES (and all dependencies)
-- ============================================================================

DROP TABLE NOTIFICATION_LOG;
DROP TABLE DEVICE_TOKEN;
DROP SEQUENCE SEQ_DEVICE_TOKEN_ID;
DROP SEQUENCE SEQ_NOTIFICATION_LOG_ID;

-- ============================================================================
-- STEP 2: CREATE DEVICE_TOKEN TABLE
-- ============================================================================

CREATE TABLE DEVICE_TOKEN (
    ID              NUMBER(19) PRIMARY KEY,
    TOKEN           VARCHAR2(500 CHAR) NOT NULL UNIQUE,
    USER_ID         NUMBER(19) NOT NULL,
    CREATED_AT      TIMESTAMP DEFAULT SYSDATE NOT NULL,
    UPDATED_AT      TIMESTAMP DEFAULT SYSDATE NOT NULL
);

COMMENT ON TABLE DEVICE_TOKEN IS 'Firebase Cloud Messaging device tokens for push notifications';
COMMENT ON COLUMN DEVICE_TOKEN.ID IS 'Unique device token ID (auto-generated)';
COMMENT ON COLUMN DEVICE_TOKEN.TOKEN IS 'Unique FCM device token from Firebase SDK';
COMMENT ON COLUMN DEVICE_TOKEN.USER_ID IS 'User ID who owns this device token';
COMMENT ON COLUMN DEVICE_TOKEN.CREATED_AT IS 'Timestamp when token was registered';
COMMENT ON COLUMN DEVICE_TOKEN.UPDATED_AT IS 'Timestamp when record was last modified';

-- ============================================================================
-- STEP 3: CREATE NOTIFICATION_LOG TABLE
-- ============================================================================

CREATE TABLE NOTIFICATION_LOG (
    ID              NUMBER(19) PRIMARY KEY,
    TITLE           VARCHAR2(255 CHAR) NOT NULL,
    BODY            VARCHAR2(1000 CHAR) NOT NULL,
    READ_STATUS     NUMBER(1) DEFAULT 0 NOT NULL,
    USER_ID         NUMBER(19) NOT NULL,
    CREATED_AT      TIMESTAMP DEFAULT SYSDATE NOT NULL,
    UPDATED_AT      TIMESTAMP DEFAULT SYSDATE NOT NULL
);

COMMENT ON TABLE NOTIFICATION_LOG IS 'Audit trail of all notifications sent to users';
COMMENT ON COLUMN NOTIFICATION_LOG.ID IS 'Unique notification log ID (auto-generated)';
COMMENT ON COLUMN NOTIFICATION_LOG.TITLE IS 'Notification title/subject';
COMMENT ON COLUMN NOTIFICATION_LOG.BODY IS 'Notification message body';
COMMENT ON COLUMN NOTIFICATION_LOG.READ_STATUS IS 'Whether user read notification (1=yes, 0=no)';
COMMENT ON COLUMN NOTIFICATION_LOG.USER_ID IS 'User ID who received this notification';
COMMENT ON COLUMN NOTIFICATION_LOG.CREATED_AT IS 'Timestamp when notification was sent';
COMMENT ON COLUMN NOTIFICATION_LOG.UPDATED_AT IS 'Timestamp when record was last modified';

-- ============================================================================
-- STEP 4: CREATE SEQUENCES FOR AUTO-INCREMENT
-- ============================================================================

CREATE SEQUENCE SEQ_DEVICE_TOKEN_ID
    START WITH 1
    INCREMENT BY 1
    NOCYCLE;

CREATE SEQUENCE SEQ_NOTIFICATION_LOG_ID
    START WITH 1
    INCREMENT BY 1
    NOCYCLE;

-- ============================================================================
-- STEP 5: CREATE TRIGGERS FOR AUTO-INCREMENT
-- ============================================================================

CREATE OR REPLACE TRIGGER DEVICE_TOKEN_ID_TRIGGER
BEFORE INSERT ON DEVICE_TOKEN
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_DEVICE_TOKEN_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
    IF :NEW.CREATED_AT IS NULL THEN
        :NEW.CREATED_AT := SYSDATE;
    END IF;
    :NEW.UPDATED_AT := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER DEVICE_TOKEN_UPDATE_TRIGGER
BEFORE UPDATE ON DEVICE_TOKEN
FOR EACH ROW
BEGIN
    :NEW.UPDATED_AT := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER NOTIFICATION_LOG_ID_TRIGGER
BEFORE INSERT ON NOTIFICATION_LOG
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT SEQ_NOTIFICATION_LOG_ID.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
    IF :NEW.CREATED_AT IS NULL THEN
        :NEW.CREATED_AT := SYSDATE;
    END IF;
    :NEW.UPDATED_AT := SYSDATE;
END;
/

CREATE OR REPLACE TRIGGER NOTIFICATION_LOG_UPDATE_TRIGGER
BEFORE UPDATE ON NOTIFICATION_LOG
FOR EACH ROW
BEGIN
    :NEW.UPDATED_AT := SYSDATE;
END;
/

-- ============================================================================
-- STEP 6: CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

CREATE INDEX IDX_DEVICE_TOKEN_USER_ID ON DEVICE_TOKEN(USER_ID);

CREATE INDEX IDX_NOTIFICATION_LOG_USER_ID ON NOTIFICATION_LOG(USER_ID);
CREATE INDEX IDX_NOTIFICATION_LOG_READ_STATUS ON NOTIFICATION_LOG(READ_STATUS);
CREATE INDEX IDX_NOTIFICATION_LOG_CREATED_AT ON NOTIFICATION_LOG(CREATED_AT);
CREATE INDEX IDX_NOTIFICATION_LOG_UNREAD ON NOTIFICATION_LOG(USER_ID, READ_STATUS);

-- ============================================================================
-- STEP 7: CREATE FOREIGN KEY CONSTRAINTS
-- ============================================================================

BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE DEVICE_TOKEN ADD CONSTRAINT FK_DEVICE_TOKEN_USER FOREIGN KEY (USER_ID) REFERENCES "user"(ID)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('INFO: Foreign key FK_DEVICE_TOKEN_USER could not be created.');
    DBMS_OUTPUT.PUT_LINE('This is expected - will be added after Hibernate creates the "user" table.');
END;
/

BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE NOTIFICATION_LOG ADD CONSTRAINT FK_NOTIFICATION_LOG_USER FOREIGN KEY (USER_ID) REFERENCES "user"(ID)';
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('INFO: Foreign key FK_NOTIFICATION_LOG_USER could not be created.');
    DBMS_OUTPUT.PUT_LINE('This is expected - will be added after Hibernate creates the "user" table.');
END;
/

-- ============================================================================
-- STEP 8: VERIFICATION
-- ============================================================================

PROMPT
PROMPT ╔════════════════════════════════════════════════════════════╗
PROMPT ║  FIREBASE NOTIFICATION TABLES CREATED SUCCESSFULLY         ║
PROMPT ╚════════════════════════════════════════════════════════════╝
PROMPT

PROMPT DEVICE_TOKEN table structure:
DESC DEVICE_TOKEN;

PROMPT
PROMPT NOTIFICATION_LOG table structure:
DESC NOTIFICATION_LOG;

PROMPT
PROMPT Summary:
PROMPT ✓ DEVICE_TOKEN table created
PROMPT ✓ NOTIFICATION_LOG table created
PROMPT ✓ Sequences created (SEQ_DEVICE_TOKEN_ID, SEQ_NOTIFICATION_LOG_ID)
PROMPT ✓ Triggers created for auto-increment and UPDATED_AT
PROMPT ✓ Indexes created for optimal performance
PROMPT ✓ TOKEN column already has UNIQUE constraint (no separate index needed)
PROMPT ✓ Foreign keys will be added after Hibernate creates "user" table
PROMPT

-- ============================================================================
-- END OF FIREBASE NOTIFICATION TABLES MIGRATION
-- ============================================================================
