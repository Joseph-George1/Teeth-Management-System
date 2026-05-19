-- Migration: Add patient_id column to PATIENT_DEVICE_TOKENS
-- Purpose: Enable matching notifications by patient_id instead of auto-generated user_id
-- Date: 2026-05-19

-- Add the patient_id column if it doesn't exist
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE PATIENT_DEVICE_TOKENS ADD (patient_id NUMBER(19))';
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('✓ Added patient_id column to PATIENT_DEVICE_TOKENS');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ patient_id column already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

-- Create index on patient_id and is_active for fast lookups
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX IDX_DEVICE_PATIENT_ACTIVE ON PATIENT_DEVICE_TOKENS(patient_id, is_active)';
  DBMS_OUTPUT.PUT_LINE('✓ Created index IDX_DEVICE_PATIENT_ACTIVE');
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      DBMS_OUTPUT.PUT_LINE('⚠ Index IDX_DEVICE_PATIENT_ACTIVE already exists - skipping');
    ELSE
      DBMS_OUTPUT.PUT_LINE('Error creating index: ' || SQLERRM);
      RAISE;
    END IF;
END;
/

COMMIT;
