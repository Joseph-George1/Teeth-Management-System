-- =====================================================================
-- BACKUP EXISTING NOTIFICATION TABLES
-- =====================================================================
-- Purpose: Safely backup current notification data before schema migration
-- Action: Run FIRST - creates backup tables
-- Location: c:\github\Teeth-Management-System\Database\
-- Date: April 4, 2026
-- =====================================================================

-- Backup DEVICE_TOKEN table (current data)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE DEVICE_TOKEN_BACKUP';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

CREATE TABLE DEVICE_TOKEN_BACKUP AS
SELECT * FROM DEVICE_TOKEN;

COMMIT;

-- Backup NOTIFICATION_LOG table if it exists
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE NOTIFICATION_LOG_BACKUP';
EXCEPTION
  WHEN OTHERS THEN NULL;
END;
/

BEGIN
  EXECUTE IMMEDIATE 'CREATE TABLE NOTIFICATION_LOG_BACKUP AS SELECT * FROM NOTIFICATION_LOG';
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

-- Verify backups created
SELECT 'DEVICE_TOKEN_BACKUP' as table_name, COUNT(*) as row_count FROM DEVICE_TOKEN_BACKUP
UNION ALL
SELECT 'NOTIFICATION_LOG_BACKUP', COUNT(*) FROM NOTIFICATION_LOG_BACKUP;

COMMIT;
