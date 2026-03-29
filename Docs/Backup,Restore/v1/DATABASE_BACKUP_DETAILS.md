# Oracle XE Database Backup & Restore - Technical Details

## 🎯 Overview

The backup system uses **Oracle Data Pump** (the native Oracle backup tool) for database backups. This ensures data integrity, consistency, and minimal performance impact on the production system.

---

## 📊 Backup Strategy

### What Gets Backed Up

```
Oracle XE Database
├── ALL SCHEMAS
│   └── All user-created schemas (not SYS, SYSTEM, etc.)
│
├── ALL OBJECTS
│   ├── Tables (with data)
│   ├── Indexes
│   ├── Views
│   ├── Stored Procedures & Functions
│   ├── Packages
│   ├── Sequences
│   ├── Triggers
│   └── Constraints
│
├── DATA (Exact Copy)
│   ├── All rows in all tables
│   ├── Password hashes (UNCHANGED)
│   ├── BLOBs and CLOBs
│   └── Data integrity intact
│
├── CONFIGURATION
│   ├── Parameter file (spfile or init file)
│   ├── Password file
│   └── Control file backup
│
└── METADATA
    ├── Table definitions
    ├── Column specifications
    ├── Data types
    ├── Constraints
    └── Indexes
```

### Excluded from Backup

- ✗ System schemas (SYS, SYSTEM, SYSAUX)
- ✗ Statistics (rebuilt automatically on import)
- ✗ Temporary objects
- ✗ Flashback logs
- ✗ Oracle managed files metadata

### Why This Approach

| Feature | Benefit |
|---------|---------|
| **Data Pump** | Oracle's native tool - guaranteed compatibility |
| **Full Export** | All user data and objects |
| **Logical Backup** | Point-in-time consistent snapshot |
| **No Downtime** | Backup while database is running |
| **Compression** | Reduces backup size |
| **Parallel Processing** | Faster backup and restore |

---

## 🔐 Data Integrity & Security

### Password Hashes - NOT MODIFIED

```bash
# Example: User password hashes are stored as-is
-- User table (example)
CREATE TABLE USERS (
    USER_ID NUMBER PRIMARY KEY,
    USERNAME VARCHAR2(50),
    PASSWORD_HASH VARCHAR2(64)  -- bcrypt or SHA256 hash
);

-- During backup and restore, PASSWORD_HASH is copied byte-for-byte
-- No decryption, no modification, no re-hashing
```

### Verification Process

```bash
# Before restore
SELECT SUM(DBMS_CRYPTO.HASH(password_hash, 3)) as hash_check
FROM users;

# After restore (will be identical)
SELECT SUM(DBMS_CRYPTO.HASH(password_hash, 3)) as hash_check
FROM users;
```

---

## 📋 Backup Files Explained

### Data Pump Export Files

```
/u01/app/oracle/admin/xe/dpdump/
├── tms_full_20260329_143022_1.dmp      # Dump file segment 1
├── tms_full_20260329_143022_2.dmp      # Dump file segment 2 (if large)
├── tms_full_20260329_143022_3.dmp      # Dump file segment 3 (if large)
├── tms_export_20260329_143022.log      # Export operation log
└── ...
```

**File Details:**
- **Format**: Binary dump format (not readable as text)
- **Size**: Varies based on database size (typically 50-200% of data volume)
- **Number**: May be split across multiple files for large databases
- **Compression**: Uses Oracle's native compression (LEVEL=1-9)

### Control Files Backup

```
control_files/
├── spfileXE.ora          # Server parameter file (binary)
├── initXE.ora            # Initialization file (text)
└── orapwXE               # Password file (binary, encrypted)
```

**Purpose:**
- `spfileXE.ora`: Database parameters (memory, processes, logs, etc.)
- `initXE.ora`: Fallback initialization file
- `orapwXE`: SYS user password (encrypted)

---

## 🔄 Backup Process Flow

### Step 1: Version Capture
```bash
sqlplus sys/$DB_PASSWORD@XE as sysdba
SQL> SELECT * FROM v$version;
SQL> SELECT * FROM dba_db_io_calibrate;
```

### Step 2: Pre-Backup Validation
```bash
# Check database status
expdp sys/$DB_PASSWORD@XE \
  ESTIMATE=STATISTICS \
  DIRECTORY=DATA_PUMP_DIR

# Verify free space
du -sh /u01/app/oracle/admin/xe/dpdump/
df -h /u01/app/oracle/
```

### Step 3: Full Database Export
```bash
expdp sys/$DB_PASSWORD@XE \
  FULL=Y \
  DUMPFILE=tms_full_%U.dmp \
  LOGFILE=tms_export.log \
  DIRECTORY=DATA_PUMP_DIR \
  PARALLEL=4 \
  COMPRESSION=MEDIUM \
  EXCLUDE=STATISTICS \
  JOB_NAME=TEETH_MGMT_BACKUP
```

**Parameters Explained:**
| Parameter | Value | Meaning |
|-----------|-------|---------|
| `FULL` | Y | Export entire database |
| `DUMPFILE` | tms_full_%U.dmp | Multiple files with sequence (%U) |
| `LOGFILE` | tms_export.log | Operation log |
| `DIRECTORY` | DATA_PUMP_DIR | Oracle directory object |
| `PARALLEL` | 4 | Use 4 parallel processes |
| `COMPRESSION` | MEDIUM | Compress dump files |
| `EXCLUDE` | STATISTICS | Don't export stats (rebuild on import) |

### Step 4: Post-Backup Validation
```bash
# Verify dump files exist
ls -lah /u01/app/oracle/admin/xe/dpdump/tms_full*.dmp

# Check export log for errors
tail -50 /u01/app/oracle/admin/xe/dpdump/tms_export.log

# Look for successful completion message:
# "Job "SYS"."TEETH_MGMT_BACKUP" completed successfully"
```

### Step 5: Archive Backup
```bash
tar -czf oracle_datapump_backup.tar.gz \
  /u01/app/oracle/admin/xe/dpdump/tms_full*.dmp \
  /u01/app/oracle/admin/xe/dpdump/tms_export.log

# Transfer to backup location
cp -r /u01/app/oracle/admin/xe/dpdump/ /backup/database/
```

---

## 🔄 Restore Process Flow

### Step 1: Pre-Restore Setup
```bash
# On NEW server with Oracle XE 21c installed

# Start Oracle
sudo systemctl start oracle-xe-21c

# Verify it's running
ps aux | grep smon
```

### Step 2: Prepare Import Directory
```bash
# Extract dump files to Oracle import directory
cd /backup/database/oracle_datapump_*
ls -la *.dmp

# Copy to Oracle's Data Pump directory
cp *.dmp /u01/app/oracle/admin/xe/dpdump/
```

### Step 3: Full Database Import
```bash
impdp sys/$DB_PASSWORD@XE \
  FULL=Y \
  DUMPFILE=tms_full_%U.dmp \
  LOGFILE=tms_import.log \
  DIRECTORY=DATA_PUMP_DIR \
  PARALLEL=4 \
  REMAP_DATAFILE='+DATA/XE/datafile/*:+DATA/XE/datafile/*' \
  JOB_NAME=TEETH_MGMT_RESTORE
```

**Parameters Explained:**
| Parameter | Value | Meaning |
|-----------|-------|---------|
| `FULL` | Y | Import entire database |
| `DUMPFILE` | tms_full_%U.dmp | Read dump files |
| `LOGFILE` | tms_import.log | Operation log |
| `DIRECTORY` | DATA_PUMP_DIR | Oracle directory object |
| `PARALLEL` | 4 | Use 4 parallel processes |
| `REMAP_DATAFILE` | (if needed) | Adjust file paths if different |

### Step 4: Post-Import Validation
```bash
# Check import log
tail -100 /u01/app/oracle/admin/xe/dpdump/tms_import.log

# Verify tables are present
sqlplus sys/$DB_PASSWORD@XE as sysdba
SQL> SELECT COUNT(*) FROM dba_tables WHERE owner NOT IN ('SYS','SYSTEM','SYSAUX');

# Verify data integrity
SQL> SELECT COUNT(*) FROM users;
SQL> SELECT COUNT(*) FROM appointments;
SQL> SELECT COUNT(*) FROM patients;

# Check for errors in logs
SQL> EXIT;
```

### Step 5: Post-Import Tasks
```bash
# Rebuild statistics
expdp sys/$DB_PASSWORD@XE \
  ESTIMATE=STATISTICS

# Update table statistics
sqlplus sys/$DB_PASSWORD@XE as sysdba
SQL> BEGIN
       DBMS_STATS.GATHER_SCHEMA_STATS(
         ownname => 'TEETH_MGMT',
         estimate_percent => DBMS_STATS.AUTO_SAMPLE_SIZE,
         method_opt => 'FOR ALL COLUMNS SIZE AUTO'
       );
     END;
     /

# Check constraints
SQL> SELECT COUNT(*) FROM dba_constraints WHERE owner = 'TEETH_MGMT';

# Exit
SQL> EXIT;
```

---

## 📊 Backup Size Estimates

### Database Size Calculation

```bash
# Get actual database size
sqlplus sys/$DB_PASSWORD@XE as sysdba
SQL> SELECT SUM(bytes)/1024/1024 AS size_mb FROM dba_segments 
     WHERE owner NOT IN ('SYS','SYSTEM','SYSAUX');

# Expected backup sizes:
# Uncompressed dump: 80-100% of data size
# Compressed dump: 30-60% of data size (with MEDIUM compression)
# + Control files: ~50MB
# + Archive file: Additional 10-20% compression
```

### Storage Requirements

```
Production Database Size: 100 GB
└─ Uncompressed dump: ~100 GB
└─ With MEDIUM compression: ~40-50 GB
└─ + Control files & config: ~50 MB
└─ Total for backup storage: ~50 GB
└─ + Extra margin (50%): ~75 GB needed at /backup
```

---

## 🛡️ Data Protection

### Checksum Verification

```bash
# During backup
sha256sum /u01/app/oracle/admin/xe/dpdump/tms_full*.dmp > checksums.txt

# During restore
sha256sum -c checksums.txt

# All checksums should show "OK"
```

### Transaction Consistency

Data Pump ensures:
- ✅ All changes within a transaction are together
- ✅ No partial transactions
- ✅ Point-in-time consistency (snapshot isolation)
- ✅ All referential constraints maintained

---

## 🔐 Encryption & Confidentiality

### In Transit
```bash
# Transfer via SCP (encrypted SSH)
scp -r /backup/ user@new-server:/backup/

# Or via RSYNC over SSH
rsync -avz --delete /backup/ user@new-server:/backup/
```

### At Rest
```bash
# Secure backup directory
chmod 700 /backup
chmod 600 /backup/database/*.dmp
chmod 600 /backup/metadata/versions*.txt

# Consider additional encryption
gpg -c backup.tar.gz  # Encrypt with password
```

### In Oracle Database
- ✅ Password hashes are bcrypt (one-way, non-reversible)
- ✅ System-managed encryption (if configured)
- ✅ No plaintext passwords in dumps
- ✅ No temporary data retained after export

---

## 🚨 Common Issues & Solutions

### Issue: "ORA-39001: invalid argument value"
```bash
# Cause: Directory object doesn't exist
# Solution: Create directory in Oracle
sqlplus sys/$DB_PASSWORD@XE as sysdba
SQL> CREATE OR REPLACE DIRECTORY DATA_PUMP_DIR 
     AS '/u01/app/oracle/admin/xe/dpdump/';
SQL> GRANT READ, WRITE ON DIRECTORY DATA_PUMP_DIR TO sys;
SQL> EXIT;
```

### Issue: "ORA-39002: invalid operation"
```bash
# Cause: Insufficient disk space
# Solution: Check space and free up disk
df -h /u01/app/oracle/admin/xe/dpdump/
# Need at least 2x database size
```

### Issue: "IMP-00017: job aborted"
```bash
# Cause: Various import failures (check log)
# Solution: Review import log
tail -200 /u01/app/oracle/admin/xe/dpdump/tms_import.log

# Check if database is in right state
sqlplus sys/$DB_PASSWORD@XE as sysdba
SQL> SELECT open_cursors FROM v$parameter WHERE name='open_cursors';
SQL> ALTER SESSION SET open_cursors=500;
```

### Issue: "Password hashes are different"
```bash
# This should NOT happen - if it does, backup failed
# Verify backup completed successfully
grep "successfully" /u01/app/oracle/admin/xe/dpdump/tms_export.log

# If dump is corrupted, re-run backup
./backup.sh
```

---

## 📝 Backup Log Example

```
Export started at 2026-03-29 14:30:22
Starting "SYS"."TEETH_MGMT_BACKUP":  sys/****@XE FULL=Y DUMPFILE=tms_full_20260329_%U.dmp LOGFILE=tms_export.log DIRECTORY=DATA_PUMP_DIR PARALLEL=4 COMPRESSION=MEDIUM EXCLUDE=STATISTICS JOB_NAME=TEETH_MGMT_BACKUP
Estimate in progress using STATISTICS method...
Processing object type DATABASE_EXPORT/PLUGTS_BLK
Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPTS/MARKER
Processing object type DATABASE_EXPORT/PRE_SYSTEM_IMPTS/PLUGTS_BLK
Processing object type DATABASE_EXPORT/EARLY_OPTIONS/PLUGTS_BLK
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/PLUGTS_BLK
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/TABLE
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/MATERIALIZED_VIEW
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/SCHEMA_EXPORT/TABLE/TABLE
Processing object type DATABASE_EXPORT/NORMAL_OPTIONS/SCHEMA_EXPORT/TABLE/INDEX/STATISTICS
Number of workers=4
Number of dump files=3
Total estimated number of FILE_ADAPTER operations=15
Total estimated number of TABLE_ADAPTER operations=42
Number of frags=2
Export completed successfully
```

---

## 🔄 Recovery Scenarios

### Scenario 1: Full Database Recovery
```bash
# Use restore.sh with complete backup
./restore.sh /backup
```

### Scenario 2: Selective Schema Recovery
```bash
# Restore single schema only
impdp sys/$DB_PASSWORD@XE \
  DUMPFILE=tms_full_%U.dmp \
  LOGFILE=schema_import.log \
  DIRECTORY=DATA_PUMP_DIR \
  SCHEMAS=TEETH_MGMT
```

### Scenario 3: Single Table Recovery
```bash
# Restore specific table
impdp sys/$DB_PASSWORD@XE \
  DUMPFILE=tms_full_%U.dmp \
  LOGFILE=table_import.log \
  DIRECTORY=DATA_PUMP_DIR \
  TABLES=TEETH_MGMT.PATIENTS
```

---

## 📞 Oracle Data Pump Documentation

- **Official Doc**: https://docs.oracle.com/en/database/oracle/oracle-database/21/sutil/
- **Export Utility**: https://docs.oracle.com/en/database/oracle/oracle-database/21/sutil/EXPDP.htm
- **Import Utility**: https://docs.oracle.com/en/database/oracle/oracle-database/21/sutil/IMPDP.htm

---

**Last Updated**: March 29, 2026  
**Oracle XE Version**: 21c  
**Teeth Management System Version**: 2.0
