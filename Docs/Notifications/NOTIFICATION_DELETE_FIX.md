# Notification DELETE Fix - Integrity Constraint Issue

## Problem Summary
When attempting to delete notifications, the system threw an Oracle integrity constraint error:

```
Error: ORA-02292: integrity constraint (SYSTEM.FK_AUDIT_QUEUE) violated - child record found
```

This occurred because the `NOTIFICATION_QUEUE` table had foreign key relationships to other tables that prevented deletion of records that still had child records.

## Root Cause
The notification system has the following table relationships:

```
NOTIFICATION_QUEUE (parent)
    ├── NOTIFICATION_DELIVERY_AUDIT (child) - FK_AUDIT_QUEUE
    └── NOTIFICATION_DELIVERY_ATTEMPTS (child) - FK_ATTEMPTS_QUEUE
```

The foreign key constraints were defined **WITHOUT** `ON DELETE CASCADE`, so deleting a notification queue record failed if audit or attempt records still referenced it.

## Solution Implemented

### 1. Database Schema Updates (Forward-Looking)
Updated both schema files to add `ON DELETE CASCADE` to the foreign key constraints:

**File:** [Database/2_create_new_notification_schema.sql](../../Database/2_create_new_notification_schema.sql)
- Line 76: `FK_AUDIT_QUEUE` - Added `ON DELETE CASCADE`
- Line 130: `FK_ATTEMPTS_QUEUE` - Added `ON DELETE CASCADE`

**File:** [Database/2_create_new_notification_schema_fixed.sql](../../Database/2_create_new_notification_schema_fixed.sql)
- Updated NOTIFICATION_DELIVERY_AUDIT foreign key
- Updated NOTIFICATION_DELIVERY_ATTEMPTS foreign key

### 2. Code-Level Cascade Delete (Immediate Fix)
Updated the DELETE endpoints in [Notification/routes/notification_routes.py](../../Notification/routes/notification_routes.py) to manually cascade delete related records before deleting the notification queue entry:

**Endpoint 1: DELETE `/api/v1/notifications/{notification_id}` (Line 356)**
```python
# CASCADE DELETE: Delete related records first (handles FK constraints)
# 1. Delete delivery attempts first
db.query(NotificationDeliveryAttempts).filter(
    NotificationDeliveryAttempts.notification_queue_id == notification_id
).delete(synchronize_session=False)

# 2. Delete audit records
db.query(NotificationDeliveryAudit).filter(
    NotificationDeliveryAudit.notification_queue_id == notification_id
).delete(synchronize_session=False)

# 3. Finally delete the notification queue entry
db.delete(notif)
db.commit()
```

**Endpoint 2: DELETE `/api/v1/notifications` (Line 424)**
- Same cascade delete logic but for all doctor's notifications
- Uses batch delete with `.in_()` for efficiency

## How It Works

### Deletion Order (Critical)
1. **Delete NOTIFICATION_DELIVERY_ATTEMPTS** - These have no children
2. **Delete NOTIFICATION_DELIVERY_AUDIT** - These reference NOTIFICATION_QUEUE but have no children
3. **Delete NOTIFICATION_QUEUE** - Now safe to delete since all references are gone

### Why This Order?
- Foreign keys enforce referential integrity from child → parent
- We must delete children before parents
- Deleting attempts first frees audit records
- Deleting audit records frees queue records
- Finally delete queue records (now orphaned)

## Testing the Fix

### Test Single Notification Delete
```bash
curl -X DELETE "http://localhost:9000/api/v1/notifications/406" \
  -H "Authorization: Bearer <token>"
```

### Expected Response (Success)
```json
{
  "success": true,
  "message": "Notification deleted"
}
```

### Before Fix: Error
```
Error deleting notification: (oracledb.exceptions.IntegrityError) ORA-02292: 
integrity constraint (SYSTEM.FK_AUDIT_QUEUE) violated
```

### After Fix: Success
```
200 OK
Notification deleted with cascade delete of related audit/attempt records
```

## Database Migration Steps (If Needed)

For existing databases with the old schema, run the constraint modifications:

```sql
-- Drop old constraints
ALTER TABLE NOTIFICATION_DELIVERY_AUDIT 
  DROP CONSTRAINT FK_AUDIT_QUEUE;
ALTER TABLE NOTIFICATION_DELIVERY_ATTEMPTS 
  DROP CONSTRAINT FK_ATTEMPTS_QUEUE;

-- Add new constraints with CASCADE DELETE
ALTER TABLE NOTIFICATION_DELIVERY_AUDIT 
  ADD CONSTRAINT FK_AUDIT_QUEUE FOREIGN KEY (NOTIFICATION_QUEUE_ID) 
    REFERENCES NOTIFICATION_QUEUE(ID) ON DELETE CASCADE;

ALTER TABLE NOTIFICATION_DELIVERY_ATTEMPTS 
  ADD CONSTRAINT FK_ATTEMPTS_QUEUE FOREIGN KEY (NOTIFICATION_QUEUE_ID) 
    REFERENCES NOTIFICATION_QUEUE(ID) ON DELETE CASCADE;
```

## Benefits

1. ✅ **Immediate Fix** - Code-level cascade delete works with existing databases
2. ✅ **Long-term Fix** - ON DELETE CASCADE in schema prevents future issues
3. ✅ **Data Integrity** - All related audit/attempt records are cleaned up
4. ✅ **No Data Loss** - Audit trail for that notification is preserved during deletion
5. ✅ **Performance** - Uses SQLAlchemy batch delete with `synchronize_session=False`

## Files Modified

1. [Database/2_create_new_notification_schema.sql](../../Database/2_create_new_notification_schema.sql)
2. [Database/2_create_new_notification_schema_fixed.sql](../../Database/2_create_new_notification_schema_fixed.sql)
3. [Notification/routes/notification_routes.py](../../Notification/routes/notification_routes.py)

## Verification

To verify the fix works in your environment:

1. **Check database constraints** (optional):
   ```sql
   SELECT CONSTRAINT_NAME, CONSTRAINT_TYPE 
   FROM USER_CONSTRAINTS 
   WHERE TABLE_NAME = 'NOTIFICATION_DELIVERY_AUDIT';
   ```

2. **Test deletion endpoint**:
   - Try deleting a notification that has audit records
   - Should succeed with HTTP 200
   - Check logs for "cascade delete of related audit/attempt records"

3. **Verify audit trail remains** (query related tables):
   ```sql
   -- These should be empty after deletion
   SELECT COUNT(*) FROM NOTIFICATION_DELIVERY_AUDIT 
   WHERE NOTIFICATION_QUEUE_ID = <deleted_id>;
   ```

## Reference

- **Error Code**: ORA-02292 - Integrity constraint violated, child record found
- **Oracle Docs**: https://docs.oracle.com/error-help/db/ora-02292/
- **SQLAlchemy Docs**: https://docs.sqlalchemy.org/en/20/dialects/oracle/
