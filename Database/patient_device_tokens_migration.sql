-- Create PATIENT_DEVICE_TOKENS table for storing Firebase Cloud Messaging (FCM) device tokens
-- This table is CRITICAL for the notification system to work
-- 
-- Flow:
-- 1. Mobile app calls POST /api/v1/device-tokens/register with FCM token
-- 2. Token saved in PATIENT_DEVICE_TOKENS table with auto-generated user_id
-- 3. Queue processor every 2 seconds:
--    a. Queries NOTIFICATION_QUEUE for pending notifications
--    b. For each pending notification:
--       - Queries this table for user's active device tokens
--       - Calls Firebase Admin SDK send_to_device() for EACH token
--       - Records FCM message ID in NOTIFICATION_DELIVERY_AUDIT
-- 4. FCM delivers push notification to mobile device
-- 5. App receives notification in onBackgroundMessage when closed

-- Drop existing sequences if they exist (for re-running migrations)
BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_patient_device_tokens_id';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'DROP SEQUENCE seq_user_id';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Create sequences FIRST
CREATE SEQUENCE seq_patient_device_tokens_id START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_user_id START WITH 1000 INCREMENT BY 1;

-- Create table with sequence defaults
CREATE TABLE PATIENT_DEVICE_TOKENS (
    id NUMBER(19) DEFAULT seq_patient_device_tokens_id.NEXTVAL PRIMARY KEY,
    user_id NUMBER(19) NOT NULL,
    fcm_token VARCHAR2(500) NOT NULL UNIQUE,
    device_type VARCHAR2(50),
    device_model VARCHAR2(100),
    os_version VARCHAR2(50),
    app_version VARCHAR2(50),
    is_active NUMBER(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT SYSDATE,
    last_used_at TIMESTAMP
);

-- Indexes for fast lookups during queue processing
CREATE INDEX IDX_DEVICE_USER_ACTIVE ON PATIENT_DEVICE_TOKENS(user_id, is_active);
CREATE INDEX IDX_DEVICE_TOKEN_ACTIVE ON PATIENT_DEVICE_TOKENS(fcm_token, is_active);
CREATE INDEX IDX_DEVICE_CREATED ON PATIENT_DEVICE_TOKENS(created_at);
CREATE INDEX IDX_DEVICE_LAST_USED ON PATIENT_DEVICE_TOKENS(last_used_at);

COMMIT;
