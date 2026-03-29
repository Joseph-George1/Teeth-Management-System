# Teeth Management System - Comprehensive Backup & Restore Guide

## 📋 Overview

This guide covers the complete backup and restore procedures for the Teeth Management System running on Ubuntu Server. The system includes:

- **Backend**: Spring Boot (Java 17) with Maven
- **Frontend**: React/Vite with Node.js
- **Web Server**: Apache 2.4
- **Application Server**: Tomcat
- **Database**: Oracle XE 21c
- **Configuration**: Apache configs, SSL certificates, system files

## 🎯 Key Features

### Backup System (`backup.sh`)
- ✅ **Version Capture**: Records all system component versions (Java, Maven, Node.js, Apache, Python, Oracle, etc.)
- ✅ **Oracle Data Pump**: Uses built-in Oracle Data Pump for full database export
- ✅ **Schema + Data + Config**: Backs up database schema, tables, data, and parameters
- ✅ **Password Hash Preservation**: No modification to password hashes (data integrity)
- ✅ **Integrity Verification**: SHA256 checksums for all backed-up files
- ✅ **Comprehensive Logging**: Detailed logs for audit and troubleshooting
- ✅ **Manifest Generation**: Complete inventory of backed-up files

### Restore System (`restore.sh`)
- ✅ **Version Verification & Matching**: Detects version mismatches
- ✅ **Automatic Correction**: Uninstalls mismatched versions and installs correct ones
- ✅ **Integrity Checks**: Verifies backup checksums before restoration
- ✅ **Selective Restore**: Can restore individual components
- ✅ **Oracle Data Pump Import**: Restores database exactly as backed up
- ✅ **Configuration Review**: Extracts configs for manual review
- ✅ **Post-Restore Validation**: Verifies restored database and services

---

## 🚀 Quick Start

### Prerequisites

**On Production Server (Backup)**
```bash
# Ensure these are installed and running
sudo systemctl status apache2
sudo systemctl status tomcat
sudo systemctl status oracle-xe-21c

# Set Oracle password environment variable
export DB_PASSWORD="your_oracle_sys_password"

# Verify Oracle Data Pump directory
ls -la /u01/app/oracle/admin/xe/dpdump/
```

**On New Server (Restore)**
```bash
# Install basic tools
sudo apt update
sudo apt install -y curl wget openjdk-17-jdk apache2 npm

# Install Oracle XE 21c (before restore)
# Follow Oracle documentation for your OS version
```

---

## 📦 Backup Procedure

### Step 1: Run Backup Script

```bash
# SSH into production server
ssh user@production-server

# Set Oracle password
export DB_PASSWORD="your_sys_password"

# Make script executable
chmod +x /path/to/backup.sh

# Run backup
./backup.sh
```

### Step 2: Monitor Backup Progress

```bash
# In another terminal, watch the log
tail -f /backup/logs/backup_*.log

# Or check backup directory structure
du -sh /backup/*
```

### Step 3: Backup Output Structure

```
/backup/
├── metadata/
│   ├── versions_20260329_143022.txt      # System versions
│   ├── manifest_20260329_143022.txt      # File inventory
│   └── checksums_20260329_143022.sha256  # Integrity hashes
├── files/
│   ├── apache2_config_20260329_143022.tar.gz
│   ├── webui_files_20260329_143022.tar.gz
│   ├── ssl_certificates_20260329_143022.tar.gz
│   ├── java_installation_20260329_143022.tar.gz
│   ├── tomcat_installation_20260329_143022.tar.gz
│   ├── backend_application_20260329_143022.tar.gz
│   ├── frontend_application_20260329_143022.tar.gz
│   ├── application_config_20260329_143022.tar.gz
│   ├── application_logs_20260329_143022.tar.gz
│   └── system_config_20260329_143022.tar.gz
├── database/
│   ├── oracle_datapump_20260329_143022/
│   │   ├── tms_full_20260329_143022_1.dmp
│   │   ├── tms_export_20260329_143022.log
│   │   └── control_files/
│   │       ├── spfileXE.ora
│   │       ├── initXE.ora
│   │       └── orapwXE
│   └── oracle_datapump_20260329_143022_backup_20260329_143022.tar.gz
└── logs/
    └── backup_20260329_143022.log
```

### Step 4: Transfer Backup to New Server

```bash
# Compress entire backup (if not already)
cd /backup
tar -czf backup_complete_20260329.tar.gz metadata/ files/ database/ logs/

# Transfer to new server (from local machine)
scp -r user@production:/backup/ /local/backup/location/

# Or via external drive
rsync -av /backup/ /mnt/external_drive/backup/
```

---

## 🔄 Restore Procedure

### Step 1: Prepare New Server

```bash
# SSH into new server
ssh user@new-server

# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y openjdk-17-jdk maven apache2 nodejs npm

# Install Oracle XE 21c (CRITICAL - must be done BEFORE restore)
# Download from: https://www.oracle.com/database/technologies/xe-downloads.html
# Follow installation guide for your OS

# Verify Oracle is running
sudo systemctl start oracle-xe-21c
sudo systemctl enable oracle-xe-21c
sudo systemctl status oracle-xe-21c

# Check Oracle is accessible
sqlplus / as sysdba
SQL> EXIT;
```

### Step 2: Prepare Backup Location

```bash
# Extract backup if compressed
cd /path/to/backup
tar -xzf backup_complete_20260329.tar.gz

# Verify backup integrity
find . -name "versions_*.txt" | head -1
find . -name "checksums_*.sha256" | head -1
```

### Step 3: Run Restore Script

```bash
# Set Oracle password
export DB_PASSWORD="your_sys_password"

# Make script executable
chmod +x restore.sh

# Run restore with backup path
./restore.sh /path/to/backup

# Or from any location
/path/to/restore.sh /backup
```

### Step 4: Monitor Restore Progress

```bash
# Watch restore log
tail -f /var/log/teeth-management/restore/restore_*.log

# Monitor Oracle import (in another terminal)
tail -f /var/log/teeth-management/restore/oracle_impdp_*.log
```

### Step 5: Post-Restore Verification

```bash
# 1. Check services
sudo systemctl status apache2
sudo systemctl status tomcat
sudo systemctl status oracle-xe-21c

# 2. Verify database restore
sqlplus sys/password@XE as sysdba
SQL> SELECT COUNT(*) FROM dba_tables WHERE owner IN (SELECT username FROM dba_users WHERE oracle_maintained='N');
SQL> EXIT;

# 3. Verify backend
cd /var/apps/teeth-management/backend
mvn clean verify

# 4. Verify frontend
cd /var/apps/teeth-management/frontend
npm install
npm run build

# 5. Check Apache configuration
sudo apache2ctl configtest

# 6. Review configuration files (extracted to /tmp/restore_config_*)
ls -la /tmp/restore_config_*/
sudo cp -r /tmp/restore_config_*/* /  # If approved
```

---

## 🔍 What Gets Backed Up

| Component | Path | Contents | Purpose |
|-----------|------|----------|---------|
| Apache2 Config | `/etc/apache2` | VirtualHosts, modules, SSL config | Web server configuration |
| Web UI Files | `/var/www/html` | HTML, CSS, JS, media | Frontend static files |
| SSL Certificates | `/etc/ssl` | .crt, .key, .pem files | HTTPS/TLS security |
| Java Installation | `/usr/lib/jvm/java-17-*` | JDK binaries | Backend runtime |
| Tomcat | `/opt/tomcat` | Server configs, libraries | Application server |
| Backend App | `/var/apps/teeth-management/backend` | Spring Boot source, built jars | Backend application |
| Frontend App | `/var/apps/teeth-management/frontend` | React/Vite source, build output | Frontend application |
| App Config | `/etc/teeth-management` | Database configs, API keys | Application settings |
| App Logs | `/var/log/teeth-management` | Error logs, access logs | Debug information |
| System Config | `/etc/hosts`, `/etc/hostname`, etc. | Network, cron, SSH | System settings |
| **Oracle XE Database** | **Data Pump Export** | **Schema, tables, data, indexes** | **All user data** |

## 🔐 Security & Data Integrity

### Password Hashes
- ✅ **No Modification**: Password hashes remain exactly as they are
- ✅ **Preservation**: All bcrypt/SHA hashes preserved character-by-character
- ✅ **Data Integrity**: Zero change to any production data
- ✅ **Confidentiality**: Hashes are secured in backup storage

### Database Integrity
- ✅ **Oracle Data Pump**: Uses Oracle's built-in tool
- ✅ **Full Export**: Complete schema, objects, and data
- ✅ **Consistency**: Logical backup (no log-based inconsistencies)
- ✅ **Integrity Checks**: SHA256 verification of backup files
- ✅ **No Transaction Logs**: Data exported at point-in-time

### Backup Security
```bash
# Secure backup location
chmod 700 /backup                    # Only owner can access
chmod 600 /backup/metadata/*         # Restrict version files
chmod 600 /backup/database/*         # Restrict database dumps

# For remote transfer
scp -r /backup/ remote_user@server:~  # SSH copy
rsync -avz --delete /backup/ /mnt/secure_drive/  # Sync to external drive
```

---

## 📝 Version Management

### Capture (Backup)
The `versions_*.txt` file contains:
```
=== OPERATING SYSTEM ===
Ubuntu 20.04.5 LTS

=== JAVA ===
openjdk version "17.0.4.1" 2022-07-19 LTS

=== MAVEN ===
Apache Maven 3.9.0

=== NODE.JS & NPM ===
v18.16.0
9.6.7

=== APACHE2 ===
Apache/2.4.41

=== TOMCAT ===
Apache Tomcat/10.1.5

=== PYTHON ===
Python 3.8.10

=== ORACLE DATABASE ===
Oracle Database 21c Express Edition Release 21.0.0.0.0

[... more versions ...]
```

### Verification (Restore)
```bash
# Check version mismatches during restore
cat /var/log/teeth-management/restore/version_mismatches_*.txt

# Automatic correction happens for:
# - Apache (uninstall new, install correct version)
# - Java (upgrade/downgrade if needed)
# - Maven (install correct version)
# - Node.js (update to correct version)
```

---

## 🛠️ Troubleshooting

### Issue: "expdp not found"
```bash
# Solution: Ensure ORACLE_HOME is set correctly
export ORACLE_HOME="/u01/app/oracle/product/21c/dbhomeXE"
export PATH="$ORACLE_HOME/bin:$PATH"
which expdp
```

### Issue: "Oracle database is not running"
```bash
# Start Oracle
sudo systemctl start oracle-xe-21c

# Enable on boot
sudo systemctl enable oracle-xe-21c

# Check status
sudo systemctl status oracle-xe-21c
```

### Issue: "Insufficient disk space"
```bash
# Check available space
df -h /backup
du -sh /backup

# Backup file size is typically:
# - Database: 50-200% of actual data size
# - Files: Similar to original size
# - Metadata: < 10MB

# Ensure 3x total data size for safety
```

### Issue: "Permission denied"
```bash
# Most operations need sudo
sudo ./restore.sh /path/to/backup

# Or run as root
su -
./restore.sh /path/to/backup
```

### Issue: "Oracle import fails"
```bash
# Check import log
tail -100 /var/log/teeth-management/restore/oracle_impdp_*.log

# Verify dump files
ls -la /u01/app/oracle/admin/xe/dpdump/*.dmp

# Check Oracle user quotas
sqlplus sys/password@XE as sysdba
SQL> SELECT username, tablespace_name, bytes FROM dba_ts_quotas;
```

---

## 🔄 Incremental Backups (Advanced)

For large systems, you can create differential backups:

```bash
# Full backup (weekly)
./backup.sh > /var/log/full_backup.log 2>&1

# Incremental database backup (daily)
expdp sys/$DB_PASSWORD@XE \
  INCREMENTAL=YES \
  DUMPFILE=incremental_%U.dmp \
  LOGFILE=incremental.log
```

---

## 📋 Checklist

### Pre-Backup Checklist
- [ ] Verify production system is stable
- [ ] Check disk space at `/backup` (3x data size minimum)
- [ ] Set `DB_PASSWORD` environment variable
- [ ] Ensure Oracle XE is running
- [ ] Test backup script on staging environment
- [ ] Notify users of backup (may impact performance)

### Pre-Restore Checklist
- [ ] New server has Ubuntu installed
- [ ] Oracle XE 21c is installed and running
- [ ] Java 17, Maven, Node.js are installed
- [ ] Backup files are accessible and verified
- [ ] 3x backup size disk space available
- [ ] Database password is known (for import)
- [ ] Backup path is correctly specified
- [ ] All team members notified of restore

### Post-Restore Checklist
- [ ] Apache2 is running (`systemctl status apache2`)
- [ ] Tomcat is running (`systemctl status tomcat`)
- [ ] Oracle XE is running (`systemctl status oracle-xe-21c`)
- [ ] Database is accessible (`sqlplus sys/***@XE`)
- [ ] Backend application builds successfully (`mvn clean install`)
- [ ] Frontend application builds successfully (`npm run build`)
- [ ] All system configurations applied from `/tmp/restore_config_*/`
- [ ] Application logs are clean (no errors)
- [ ] SSL certificates are installed and valid
- [ ] Web application is accessible via browser

---

## 📞 Support

For issues or questions:

1. **Check Backup Log**: `/backup/logs/backup_*.log`
2. **Check Restore Log**: `/var/log/teeth-management/restore/restore_*.log`
3. **Check Oracle Logs**: `/u01/app/oracle/diag/rdbms/xe/XE/trace/`
4. **Review Version File**: `backup/metadata/versions_*.txt`
5. **Check Manifest**: `backup/metadata/manifest_*.txt`

---

## 📜 License

Part of the Teeth Management System backup/restore framework.

**Version**: 2.0  
**Last Updated**: March 29, 2026  
**Maintained By**: System Administration Team
