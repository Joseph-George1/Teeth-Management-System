-- Update categories with correct Arabic spelling
UPDATE CATEGORY SET NAME = 'تركيبات متحركة' WHERE NAME = 'تريكيبات متحركة';
UPDATE CATEGORY SET NAME = 'زراعة الأسنان' WHERE NAME = 'زراعة الاسنان';
UPDATE CATEGORY SET NAME = 'تنظيف وتبييض الأسنان' WHERE NAME = 'تنظيف وتبييض';
UPDATE CATEGORY SET NAME = 'تقويم الأسنان' WHERE NAME = 'تقويم الاسنان';
UPDATE CATEGORY SET NAME = 'طب أسنان الأطفال' WHERE NAME = 'الاطفال';

COMMIT;
