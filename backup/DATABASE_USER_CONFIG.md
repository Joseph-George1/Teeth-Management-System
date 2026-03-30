# Database User Configuration Note

## Oracle Database User Setup

### Application vs Backup/Restore Users

**Application User (from application.properties):**
- **Username**: `system`
- **Purpose**: Used by Spring Boot application for normal database operations
- **Privileges**: Standard user privileges for CRUD operations on application tables
- **Configuration**: `DB_USERNAME=system` in `application.properties`

**Backup/Restore User:**
- **Username**: `sys`
- **Purpose**: Used for full database backup and restore operations
- **Privileges**: SYSDBA privileges required for `expdp full=y` and `impdp full=y`
- **Why sys?**: Only users with SYSDBA privileges can perform full database exports/imports

### Why Different Users?

1. **Security Principle**: Application uses least-privilege user for normal operations
2. **Technical Requirement**: Full database operations require SYSDBA privileges
3. **Oracle Design**: `sys` is the default SYSDBA user, `system` is the default DBA user

### Password Configuration

Both users use the **same password** (your Oracle XE password). Update this line in both scripts:

```bash
# In backup.sh and restore.sh
DB_PASSWORD="YOUR_ACTUAL_ORACLE_PASSWORD_HERE"
```

### Verification

The database verification during restore still uses `sys` for SYSDBA access to query system views like:
- `dba_tables` - List all tables
- `dba_users` - List all users
- `dba_tablespaces` - List all tablespaces

This ensures complete verification of the restored database.

---

## Summary

- **Application**: Uses `system` user (from application.properties)
- **Backup**: Uses `sys` user (SYSDBA privileges required)
- **Password**: Same for both users
- **Data Integrity**: Password hashes remain unchanged during backup/restore