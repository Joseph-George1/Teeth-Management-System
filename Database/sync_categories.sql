-- Revised SQL script to synchronize categories with the 10 required ones
-- This script handles duplicates by merging names to IDs (1-10) and updating references.
-- 1. Create a temporary table for our target list
DECLARE
    TYPE cat_rec IS RECORD (id NUMBER, name VARCHAR2(255));
    TYPE cat_list IS TABLE OF cat_rec;
    targets cat_list := cat_list(
        cat_rec(1, 'حشو تجميلي'),
        cat_rec(2, 'حشو املجم'),
        cat_rec(3, 'حشو عصب'),
        cat_rec(4, 'تيجان وجسور'),
        cat_rec(5, 'تريكيبات متحركة'),
        cat_rec(6, 'زراعة الاسنان'),
        cat_rec(7, 'تنظيف وتبييض'),
        cat_rec(8, 'تقويم الاسنان'),
        cat_rec(9, 'الجراحة والخلع'),
        cat_rec(10, 'الاطفال')
    );
    existing_id NUMBER;
BEGIN
    FOR i IN targets.FIRST .. targets.LAST LOOP
        -- A. Find if this name exists under a different ID
        BEGIN
            SELECT id INTO existing_id FROM CATEGORY WHERE name = targets(i).name AND id != targets(i).id AND ROWNUM = 1;
            
            -- B. Update DOCTOR references
            UPDATE DOCTOR SET category_id = targets(i).id WHERE category_id = existing_id;
            
            -- C. Update Requests references
            UPDATE Requests SET category_id = targets(i).id WHERE category_id = existing_id;
            
            -- D. Delete the old redundant category (now it has no children)
            DELETE FROM CATEGORY WHERE id = existing_id;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN NULL;
        END;

        -- E. Ensure the target ID exists with the target Name
        -- First, if another record has this target ID but a DIFFERENT name, we might have a conflict
        -- But our MERGE handles it by updating the name.
        -- However, if another record has the target NAME but a DIFFERENT ID, we already handled it above.
        
        BEGIN
            -- Ensure the target ID exists
            INSERT INTO CATEGORY (id, name) VALUES (targets(i).id, targets(i).name);
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                -- If ID already exists, update the name
                UPDATE CATEGORY SET name = targets(i).name WHERE id = targets(i).id;
        END;
    END LOOP;

    -- 2. Handle any remaining categories that are NOT in the target list (IDs 1-10)
    -- This includes categories with names NOT in the target list.
    -- To be safe, we only delete those that are NOT referenced.
    DELETE FROM CATEGORY
    WHERE id NOT BETWEEN 1 AND 10
      AND id NOT IN (SELECT category_id FROM DOCTOR WHERE category_id IS NOT NULL)
      AND id NOT IN (SELECT category_id FROM Requests WHERE category_id IS NOT NULL);

    COMMIT;
END;
/
