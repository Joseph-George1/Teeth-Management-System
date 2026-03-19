-- SQL script to synchronize categories with the 10 required ones
-- We use a safer approach to avoid ORA-02292: integrity constraint violation

-- 1. Identify categories that are NOT in the target list
-- Instead of deleting them, we can try to rename them if possible, or just leave them
-- if they are referenced. However, the requirement is to "remove all categories and only include these 10".

-- To handle references, we can't easily delete.
-- Strategy:
-- A. Update existing categories to match the new names where possible.
-- B. Insert new categories if they don't exist.
-- C. If there are extra categories that are NOT in the list, we might have to keep them if they are referenced,
--    but we can mark them as 'OLD_' or similar if we wanted.
--    Or, we can try to delete only those that are NOT referenced.

-- First, let's ensure the 10 categories exist.
-- We use MERGE to either update or insert.

MERGE INTO CATEGORY t
USING (
    SELECT 1 AS id, 'حشو تجميلي' AS name FROM DUAL UNION ALL
    SELECT 2 AS id, 'حشو املجم' AS name FROM DUAL UNION ALL
    SELECT 3 AS id, 'حشو عصب' AS name FROM DUAL UNION ALL
    SELECT 4 AS id, 'تيجان وجسور' AS name FROM DUAL UNION ALL
    SELECT 5 AS id, 'تريكيبات متحركة' AS name FROM DUAL UNION ALL
    SELECT 6 AS id, 'زراعة الاسنان' AS name FROM DUAL UNION ALL
    SELECT 7 AS id, 'تنظيف وتبييض' AS name FROM DUAL UNION ALL
    SELECT 8 AS id, 'تقويم الاسنان' AS name FROM DUAL UNION ALL
    SELECT 9 AS id, 'الجراحة والخلع' AS name FROM DUAL UNION ALL
    SELECT 10 AS id, 'الاطفال' AS name FROM DUAL
) s
ON (t.ID = s.id)
WHEN MATCHED THEN
    UPDATE SET t.NAME = s.name
WHEN NOT MATCHED THEN
    INSERT (ID, NAME) VALUES (s.id, s.name);

-- Now, for categories that are NOT in the list of IDs (1-10)
-- and NOT in our target names.
-- We try to delete only those that are NOT referenced by Doctors or Requests.

DELETE FROM CATEGORY
WHERE ID NOT BETWEEN 1 AND 10
  AND NAME NOT IN (
    'حشو تجميلي', 'حشو املجم', 'حشو عصب', 'تيجان وجسور', 'تريكيبات متحركة',
    'زراعة الاسنان', 'تنظيف وتبييض', 'تقويم الاسنان', 'الجراحة والخلع', 'الاطفال'
  )
  AND ID NOT IN (SELECT category_id FROM DOCTOR WHERE category_id IS NOT NULL)
  AND ID NOT IN (SELECT category_id FROM Requests WHERE category_id IS NOT NULL);

-- For those that ARE referenced but not in our 10, we can't delete them.
-- They will remain in the database but won't be easily accessible from the UI if the UI only fetches 1-10
-- or if the AI chatbot only uses the 10 names.

COMMIT;
