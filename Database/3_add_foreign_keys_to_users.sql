-- =====================================================================
-- ADD FOREIGN KEY CONSTRAINTS TO USERS TABLE
-- =====================================================================
-- Purpose: Add foreign key constraints to NOTIFICATION tables linking to USERS
-- Prerequisites: USERS table must exist in the same schema
-- Run this AFTER 2_create_new_notification_schema_fixed.sql
-- =====================================================================

SET ECHO ON;
SET FEEDBACK ON;

-- Add FK to NOTIFICATION_QUEUE
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE NOTIFICATION_QUEUE ADD CONSTRAINT FK_NOTIFICATION_QUEUE_USER FOREIGN KEY (USER_ID) REFERENCES USERS(ID)';
    DBMS_OUTPUT.PUT_LINE('✓ Added FK: NOTIFICATION_QUEUE -> USERS');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -1439 THEN
        DBMS_OUTPUT.PUT_LINE('✓ FK_NOTIFICATION_QUEUE_USER already exists');
      ELSIF SQLCODE = -2268 THEN
        DBMS_OUTPUT.PUT_LINE('⚠ USERS table not found - ensure USERS table exists before running this script');
      ELSE
        DBMS_OUTPUT.PUT_LINE('⚠ Error adding FK: ' || SQLERRM);
      END IF;
  END;
END;
/

-- Add FK to NOTIFICATION_PREFERENCES
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE NOTIFICATION_PREFERENCES ADD CONSTRAINT FK_PREFERENCES_USER FOREIGN KEY (USER_ID) REFERENCES USERS(ID)';
    DBMS_OUTPUT.PUT_LINE('✓ Added FK: NOTIFICATION_PREFERENCES -> USERS');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -1439 THEN
        DBMS_OUTPUT.PUT_LINE('✓ FK_PREFERENCES_USER already exists');
      ELSIF SQLCODE = -2268 THEN
        DBMS_OUTPUT.PUT_LINE('⚠ USERS table not found');
      ELSE
        DBMS_OUTPUT.PUT_LINE('⚠ Error adding FK: ' || SQLERRM);
      END IF;
  END;
END;
/

-- Add FK to NOTIFICATION_LOGS
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 'ALTER TABLE NOTIFICATION_LOGS ADD CONSTRAINT FK_NOTIFICATION_LOGS_USER FOREIGN KEY (RECIPIENT_USER_ID) REFERENCES USERS(ID)';
    DBMS_OUTPUT.PUT_LINE('✓ Added FK: NOTIFICATION_LOGS -> USERS');
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -1439 THEN
        DBMS_OUTPUT.PUT_LINE('✓ FK_NOTIFICATION_LOGS_USER already exists');
      ELSIF SQLCODE = -2268 THEN
        DBMS_OUTPUT.PUT_LINE('⚠ USERS table not found');
      ELSE
        DBMS_OUTPUT.PUT_LINE('⚠ Error adding FK: ' || SQLERRM);
      END IF;
  END;
END;
/

COMMIT;
/

BEGIN
  DBMS_OUTPUT.PUT_LINE('');
  DBMS_OUTPUT.PUT_LINE('=== FOREIGN KEY SETUP COMPLETE ===');
END;
/
