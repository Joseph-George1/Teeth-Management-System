-- Firebase Notification System Tables
-- Created: April 3, 2026
-- Purpose: Store device tokens and notification logs for Firebase Cloud Messaging

-- ============================================================
-- Table 1: DEVICE_TOKEN
-- Purpose: Store FCM device tokens for each user
-- ============================================================
CREATE TABLE DEVICE_TOKEN (
    ID NUMBER PRIMARY KEY,
    TOKEN VARCHAR2(255) NOT NULL,
    USER_ID NUMBER NOT NULL,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (USER_ID) REFERENCES USERS(ID) ON DELETE CASCADE
);

-- Create sequence for DEVICE_TOKEN ID
CREATE SEQUENCE DEVICE_TOKEN_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create index on USER_ID for faster queries
CREATE INDEX IDX_DEVICE_TOKEN_USER_ID ON DEVICE_TOKEN(USER_ID);

-- Create unique index to prevent duplicate tokens per user
CREATE UNIQUE INDEX IDX_DEVICE_TOKEN_UNIQUE ON DEVICE_TOKEN(TOKEN, USER_ID);

-- Create trigger for auto-increment ID
CREATE OR REPLACE TRIGGER DEVICE_TOKEN_TRIGGER
BEFORE INSERT ON DEVICE_TOKEN
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT DEVICE_TOKEN_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- Table 2: NOTIFICATION_LOG
-- Purpose: Track all sent notifications and read status
-- ============================================================
CREATE TABLE NOTIFICATION_LOG (
    ID NUMBER PRIMARY KEY,
    TITLE VARCHAR2(255) NOT NULL,
    BODY VARCHAR2(1000) NOT NULL,
    READ_STATUS NUMBER(1) DEFAULT 0,
    USER_ID NUMBER NOT NULL,
    CREATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (USER_ID) REFERENCES USERS(ID) ON DELETE CASCADE
);

-- Create sequence for NOTIFICATION_LOG ID
CREATE SEQUENCE NOTIFICATION_LOG_SEQ
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create index on USER_ID for faster queries
CREATE INDEX IDX_NOTIFICATION_LOG_USER_ID ON NOTIFICATION_LOG(USER_ID);

-- Create index on READ_STATUS for filtering unread notifications
CREATE INDEX IDX_NOTIFICATION_LOG_READ_STATUS ON NOTIFICATION_LOG(READ_STATUS);

-- Create index on CREATED_AT for sorting notifications by date
CREATE INDEX IDX_NOTIFICATION_LOG_CREATED_AT ON NOTIFICATION_LOG(CREATED_AT);

-- Create trigger for auto-increment ID
CREATE OR REPLACE TRIGGER NOTIFICATION_LOG_TRIGGER
BEFORE INSERT ON NOTIFICATION_LOG
FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN
        SELECT NOTIFICATION_LOG_SEQ.NEXTVAL INTO :NEW.ID FROM DUAL;
    END IF;
END;
/

-- ============================================================
-- VERIFICATION QUERIES
-- ============================================================

-- Check DEVICE_TOKEN table structure
DESC DEVICE_TOKEN;

-- Check NOTIFICATION_LOG table structure
DESC NOTIFICATION_LOG;

-- Sample queries to verify tables work
-- Get all tokens for a user
SELECT TOKEN FROM DEVICE_TOKEN WHERE USER_ID = 1;

-- Get unread notifications for a user
SELECT * FROM NOTIFICATION_LOG WHERE USER_ID = 1 AND READ_STATUS = 0 ORDER BY CREATED_AT DESC;

-- Get all notifications for a user
SELECT * FROM NOTIFICATION_LOG WHERE USER_ID = 1 ORDER BY CREATED_AT DESC;

-- ============================================================
-- End of Firebase Notification Tables Migration
-- ============================================================
