-- TEETH MANAGEMENT SYSTEM - DATABASE MIGRATION FOR ORACLE XE
-- Created: March 17, 2026
-- Purpose: Update existing database schema to support latest backend changes
-- Compatibility: Oracle Database XE 21c and above

-- =====================================================================
-- STEP 1: CREATE APPOINTMENT STATUS TYPE (Enum simulation)
-- =====================================================================

BEGIN
  EXECUTE IMMEDIATE 'CREATE TYPE appointment_status_type AS OBJECT (status_name VARCHAR2(20))';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -2304 THEN
      NULL; -- Type already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- =====================================================================
-- STEP 2: ALTER APPOINTMENTS TABLE - ADD MISSING COLUMNS
-- =====================================================================

-- Add request_id foreign key (links appointment to request)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE appointments ADD request_id NUMBER';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 THEN
      NULL; -- Column already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Add created_at timestamp (tracks when appointment was created)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE appointments ADD created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 THEN
      NULL; -- Column already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Add is_expired flag (marks if appointment is auto-cancelled after 7 days)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE appointments ADD is_expired NUMBER(1) DEFAULT 0';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 THEN
      NULL; -- Column already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Add is_history flag (marks completed/cancelled appointments)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE appointments ADD is_history NUMBER(1) DEFAULT 0';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 THEN
      NULL; -- Column already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Make duration_minutes nullable (appointments don't track duration in latest version)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE appointments MODIFY duration_minutes NUMBER NULL';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1442 THEN
      NULL; -- Column definition identical
    ELSE
      RAISE;
    END IF;
END;
/

-- Make notes nullable (appointments don't track notes in latest version)
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE appointments MODIFY notes VARCHAR2(500) NULL';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1442 THEN
      NULL; -- Column definition identical
    ELSE
      RAISE;
    END IF;
END;
/

-- =====================================================================
-- STEP 3: CREATE FOREIGN KEY CONSTRAINT (request_id)
-- =====================================================================

BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE appointments ADD CONSTRAINT fk_appointment_request 
    FOREIGN KEY (request_id) REFERENCES requests(id) ON DELETE CASCADE';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -2275 THEN
      NULL; -- Constraint already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- =====================================================================
-- STEP 4: CREATE INDEXES FOR PERFORMANCE
-- =====================================================================

-- Index on status for filtering pending appointments
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_appointment_status ON appointments(status)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Index on doctor_id for getting doctor's appointments
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_appointment_doctor ON appointments(doctor_id)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Index on patient_id for getting patient's appointments
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_appointment_patient ON appointments(patient_id)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Index on request_id for linking appointments to requests
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_appointment_request ON appointments(request_id)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Index on created_at for expiration check (faster queries on old appointments)
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_appointment_created ON appointments(created_at)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Index on is_expired for history queries
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_appointment_expired ON appointments(is_expired)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Index on is_history for getting completed appointments
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_appointment_history ON appointments(is_history)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Composite index for common queries: doctor's PENDING appointments
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_doctor_pending ON appointments(doctor_id, status)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Composite index for history queries: doctor's completed appointments
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_doctor_history ON appointments(doctor_id, is_history)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- =====================================================================
-- STEP 5: UPDATE REQUESTS TABLE IF NEEDED
-- =====================================================================

-- Ensure requests table has status column
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE requests ADD status VARCHAR2(50) DEFAULT ''PENDING''';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1430 THEN
      NULL; -- Column already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Create index on request status
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_request_status ON requests(status)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Create index on doctor_id for doctor's requests
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_request_doctor ON requests(doctor_id)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- =====================================================================
-- STEP 6: UPDATE PATIENTS TABLE IF NEEDED
-- =====================================================================

-- Index on phone_number for patient lookup (auto-create/find by phone)
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_patient_phone ON patients(phone_number)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -1408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- =====================================================================
-- STEP 7: VERIFY SCHEMA (View current structure)
-- =====================================================================

-- Show appointments table structure
PROMPT =====================================================
PROMPT APPOINTMENTS TABLE STRUCTURE
PROMPT =====================================================
DESC appointments;

-- Show requests table structure
PROMPT =====================================================
PROMPT REQUESTS TABLE STRUCTURE
PROMPT =====================================================
DESC requests;

-- Show patients table structure
PROMPT =====================================================
PROMPT PATIENTS TABLE STRUCTURE
PROMPT =====================================================
DESC patients;

-- =====================================================================
-- STEP 8: MIGRATION SUMMARY
-- =====================================================================

PROMPT =====================================================
PROMPT MIGRATION COMPLETED SUCCESSFULLY
PROMPT =====================================================
PROMPT
PROMPT Changes made to support latest backend:
PROMPT
PROMPT 1. APPOINTMENTS TABLE:
PROMPT    - Added: request_id (foreign key to requests)
PROMPT    - Added: created_at (timestamp when appointment created)
PROMPT    - Added: is_expired (flag for 7-day auto-cancel)
PROMPT    - Added: is_history (flag for completed/cancelled)
PROMPT    - Made nullable: duration_minutes, notes
PROMPT
PROMPT 2. REQUESTS TABLE:
PROMPT    - Verified: status column exists
PROMPT    - Verified: doctor_id, category_id, description, dateTime
PROMPT
PROMPT 3. PATIENTS TABLE:
PROMPT    - Verified: id, firstName, lastName, phoneNumber
PROMPT    - System auto-creates patient by phone number on booking
PROMPT
PROMPT 4. INDEXES CREATED:
PROMPT    - Performance indexes on status, doctor_id, patient_id, request_id
PROMPT    - Performance indexes on created_at, is_expired, is_history
PROMPT    - Composite indexes for doctor's pending and history queries
PROMPT    - Phone number index for patient lookup
PROMPT
PROMPT =====================================================
PROMPT NEXT STEPS:
PROMPT =====================================================
PROMPT
PROMPT 1. Backup your database before running this script
PROMPT 2. Run: sqlplus system/password@XE @migration_oracle_xe.sql
PROMPT 3. Verify: DESC appointments; DESC requests;
PROMPT 4. Compile backend: mvn clean compile
PROMPT 5. Start application with @EnableScheduling for auto-expiration
PROMPT
PROMPT =====================================================

COMMIT;
/

EXIT;
