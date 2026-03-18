-- TEETH MANAGEMENT SYSTEM - DATABASE UPDATE FOR ADMIN DASHBOARD
-- Created: March 17, 2026
-- Purpose: Add indexes and ensure status columns exist for the new statistics
-- Compatibility: Oracle Database (orclpdb)

-- =====================================================================
-- STEP 1: ENSURE STATUS COLUMNS EXIST AND HAVE PROPER TYPES
-- =====================================================================

-- Appointments status is already EnumType.STRING in Java, usually mapped to VARCHAR2
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE appointments MODIFY status VARCHAR2(20) DEFAULT ''PENDING''';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -01442 THEN
      NULL; -- Column already NOT NULL or same definition
    ELSE
      RAISE;
    END IF;
END;
/

-- Ensure Requests has status column
BEGIN
  EXECUTE IMMEDIATE 'ALTER TABLE requests ADD status VARCHAR2(20) DEFAULT ''PENDING''';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -01430 THEN
      NULL; -- Column already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- =====================================================================
-- STEP 2: CREATE INDEXES FOR DASHBOARD STATISTICS PERFORMANCE
-- =====================================================================

-- Index for appointment status counts
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_appointment_status_count ON appointments(status)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -01408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- Index for request status counts
BEGIN
  EXECUTE IMMEDIATE 'CREATE INDEX idx_request_status_count ON requests(status)';
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = -01408 THEN
      NULL; -- Index already exists
    ELSE
      RAISE;
    END IF;
END;
/

-- =====================================================================
-- STEP 3: MIGRATION SUMMARY
-- =====================================================================

PROMPT =====================================================
PROMPT DATABASE UPDATES FOR ADMIN DASHBOARD COMPLETED
PROMPT =====================================================
PROMPT 
PROMPT 1. Verified status column in REQUESTS table.
PROMPT 2. Created performance index on APPOINTMENTS(status).
PROMPT 3. Created performance index on REQUESTS(status).
PROMPT
PROMPT Note: spring.jpa.hibernate.ddl-auto=update will handle 
PROMPT basic schema changes, but indexes are added for speed.
PROMPT =====================================================

COMMIT;
/
