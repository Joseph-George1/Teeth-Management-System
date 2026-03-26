-- SQL Script to update Categories in Teeth Management System
-- This script updates existing category names and ensures all 10 required categories exist.

-- 1. Update existing names to match the new Arabic requirements
UPDATE category SET name = 'حشو تجميلي' WHERE name LIKE '%Cosmetic%' OR name = 'حشو تجميلي';
UPDATE category SET name = 'حشو املجم' WHERE name LIKE '%Amalgam%' OR name = 'حشو املجم';
UPDATE category SET name = 'حشو عصب' WHERE name LIKE '%Endodontic%' OR name LIKE '%حشوات علاج الجذور%' OR name = 'حشو عصب';
UPDATE category SET name = 'تيجان وجسور' WHERE name LIKE '%Fixed Prosthetics%' OR name = 'تيجان وجسور';
UPDATE category SET name = 'تريكيبات متحركة' WHERE name = 'Removable Prosthetics' OR name = 'تركيبات متحركة' OR name = 'تريكيبات متحركة';
UPDATE category SET name = 'زراعة الاسنان' WHERE name = 'Dental Implants' OR name = 'زراعة الاسنان';
UPDATE category SET name = 'تنظيف وتبييض' WHERE name = 'Cleaning and Whitening' OR name = 'تبيض اسنان' OR name = 'تنظيف وتبييض';
UPDATE category SET name = 'تقويم الاسنان' WHERE name = 'Orthodontics' OR name = 'تقويم الاسنان';
UPDATE category SET name = 'الجراحة والخلع' WHERE name = 'Surgery and Extraction' OR name = 'الجراحة والخلع';
UPDATE category SET name = 'الاطفال' WHERE name = 'Pediatric Dentistry' OR name = 'الاطفال';

-- 2. Insert missing categories if they don't exist
INSERT INTO category (name) SELECT 'حشو تجميلي' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'حشو تجميلي');
INSERT INTO category (name) SELECT 'حشو املجم' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'حشو املجم');
INSERT INTO category (name) SELECT 'حشو عصب' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'حشو عصب');
INSERT INTO category (name) SELECT 'تيجان وجسور' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'تيجان وجسور');
INSERT INTO category (name) SELECT 'تريكيبات متحركة' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'تريكيبات متحركة');
INSERT INTO category (name) SELECT 'زراعة الاسنان' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'زراعة الاسنان');
INSERT INTO category (name) SELECT 'تنظيف وتبييض' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'تنظيف وتبييض');
INSERT INTO category (name) SELECT 'تقويم الاسنان' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'تقويم الاسنان');
INSERT INTO category (name) SELECT 'الجراحة والخلع' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'الجراحة والخلع');
INSERT INTO category (name) SELECT 'الاطفال' FROM dual WHERE NOT EXISTS (SELECT 1 FROM category WHERE name = 'الاطفال');

COMMIT;
