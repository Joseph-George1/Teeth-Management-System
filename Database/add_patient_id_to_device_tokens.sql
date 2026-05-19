-- ==============================================================================
-- Comprehensive Migration: PATIENT_DEVICE_TOKENS Table with patient_id Support
-- ==============================================================================
--
-- Purpose: 
--   1. Create PATIENT_DEVICE_TOKENS table (if needed)
--   2. Add patient_id column for matching notifications by patient_id from backend
--   3. Create all necessary indexes for fast queue processing
--
-- Background:
--   Devices are registered with auto-generated user_id
--   But notifications are queued with patient_id from backend database
--   This migration enables matching via patient_id
--   
-- Date: 2026-05-19
-- ==============================================================================

-- Step 1: Create sequences if they don't exist
BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_patient_device_tokens_id START WITH 1 INCREMENT BY 1';
  DBMS_OUTPUT.PUT_LINE('✓ Created sequence seq_patient_device_tokens_id');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -955 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Sequence seq_patient_device_tokens_id already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE SEQUENCE seq_user_id START WITH 1000 INCREMENT BY 1';
  DBMS_OUTPUT.PUT_LINE('✓ Created sequence seq_user_id');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -955 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Sequence seq_user_id already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

-- Step 2: Create PATIENT_DEVICE_TOKENS table if it doesn't exist
BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE PATIENT_DEVICE_TOKENS (
    id NUMBER(19) DEFAULT seq_patient_device_tokens_id.NEXTVAL PRIMARY KEY,
    user_id NUMBER(19) NOT NULL,
    patient_id NUMBER(19),
    fcm_token VARCHAR2(500) NOT NULL UNIQUE,
    device_type VARCHAR2(50),
    device_model VARCHAR2(100),
    os_version VARCHAR2(50),
    app_version VARCHAR2(50),
    is_active NUMBER(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT SYSDATE,
    last_used_at TIMESTAMP
  )';
  DBMS_OUTPUT.PUT_LINE('✓ Created PATIENT_DEVICE_TOKENS table');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -955 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Table PATIENT_DEVICE_TOKENS already exists - table creation skipped');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

-- Step 3: Add patient_id column if it doesn't exist
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE PATIENT_DEVICE_TOKENS ADD (patient_id NUMBER(19))';
  DBMS_OUTPUT.PUT_LINE('✓ Added patient_id column to PATIENT_DEVICE_TOKENS');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Column patient_id already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

-- Step 4: Create all indexes
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_DEVICE_USER_ACTIVE ON PATIENT_DEVICE_TOKENS(user_id, is_active)';
  DBMS_OUTPUT.PUT_LINE('✓ Created index IDX_DEVICE_USER_ACTIVE');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Index IDX_DEVICE_USER_ACTIVE already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_DEVICE_PATIENT_ACTIVE ON PATIENT_DEVICE_TOKENS(patient_id, is_active)';
  DBMS_OUTPUT.PUT_LINE('✓ Created index IDX_DEVICE_PATIENT_ACTIVE');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Index IDX_DEVICE_PATIENT_ACTIVE already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_DEVICE_TOKEN_ACTIVE ON PATIENT_DEVICE_TOKENS(fcm_token, is_active)';
  DBMS_OUTPUT.PUT_LINE('✓ Created index IDX_DEVICE_TOKEN_ACTIVE');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Index IDX_DEVICE_TOKEN_ACTIVE already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_DEVICE_CREATED ON PATIENT_DEVICE_TOKENS(created_at)';
  DBMS_OUTPUT.PUT_LINE('✓ Created index IDX_DEVICE_CREATED');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Index IDX_DEVICE_CREATED already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

COMMIT;
DBMS_OUTPUT.PUT_LINE('✓ Migration completed successfully');
