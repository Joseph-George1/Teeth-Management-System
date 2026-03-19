-- SQL script to synchronize categories with the 10 required ones
-- Delete categories that are not in the new list (to be safe, though we mostly add/rename)
DELETE FROM CATEGORY WHERE NAME NOT IN (
    'حشو تجميلي',
    'حشو املجم',
    'حشو عصب',
    'تيجان وجسور',
    'تريكيبات متحركة',
    'زراعة الاسنان',
    'تنظيف وتبييض',
    'تقويم الاسنان',
    'الجراحة والخلع',
    'الاطفال'
);

-- Insert missing categories
INSERT INTO CATEGORY (ID, NAME)
SELECT 1, 'حشو تجميلي' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'حشو تجميلي');

INSERT INTO CATEGORY (ID, NAME)
SELECT 2, 'حشو املجم' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'حشو املجم');

INSERT INTO CATEGORY (ID, NAME)
SELECT 3, 'حشو عصب' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'حشو عصب');

INSERT INTO CATEGORY (ID, NAME)
SELECT 4, 'تيجان وجسور' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'تيجان وجسور');

INSERT INTO CATEGORY (ID, NAME)
SELECT 5, 'تريكيبات متحركة' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'تريكيبات متحركة');

INSERT INTO CATEGORY (ID, NAME)
SELECT 6, 'زراعة الاسنان' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'زراعة الاسنان');

INSERT INTO CATEGORY (ID, NAME)
SELECT 7, 'تنظيف وتبييض' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'تنظيف وتبييض');

INSERT INTO CATEGORY (ID, NAME)
SELECT 8, 'تقويم الاسنان' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'تقويم الاسنان');

INSERT INTO CATEGORY (ID, NAME)
SELECT 9, 'الجراحة والخلع' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'الجراحة والخلع');

INSERT INTO CATEGORY (ID, NAME)
SELECT 10, 'الاطفال' FROM DUAL WHERE NOT EXISTS (SELECT 1 FROM CATEGORY WHERE NAME = 'الاطفال');

COMMIT;
