-- =====================================================================
-- DROP OLD FIREBASE NOTIFICATION TABLES
-- =====================================================================
-- Purpose: Remove old Firebase-specific notification tables
-- Action: Run SECOND - after backing up data
-- Safety: Uses DROP TABLE IF EXISTS for safety
-- Location: c:\github\Teeth-Management-System\Database\
-- Date: April 4, 2026
-- =====================================================================

-- Drop old NOTIFICATION_LOG table (will be recreated with new schema)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE NOTIFICATION_LOG CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Drop old DEVICE_TOKEN table (will be recreated with enhanced schema)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE DEVICE_TOKEN CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Drop old NOTIFICATION_PREFERENCES if it exists
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE NOTIFICATION_PREFERENCES CASCADE CONSTRAINTS';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

-- Verify tables dropped
SELECT table_name FROM user_tables 
WHERE table_name IN ('DEVICE_TOKEN', 'NOTIFICATION_LOG', 'NOTIFICATION_PREFERENCES')
ORDER BY table_name;

-- Should return 0 rows if successful

COMMIT;
