# Backup/Restore Scripts - Modifications Summary

**Date**: March 29, 2026  
**Status**: ✅ Complete

## Overview
All backup.sh, restore.sh, and setup.sh scripts have been updated to align with the **actual project structure and deployment model** discovered through analysis of the astart and install.sh files.

---

## Key Changes Made

### 1. **Path Configuration Updates** 

#### Removed Non-Existent Production Paths
The following paths were removed as they represent future production deployment targets, not current system structure:
- ❌ `/var/apps/teeth-management/backend`
- ❌ `/var/apps/teeth-management/frontend`
- ❌ `/etc/teeth-management`
- ❌ `/var/log/teeth-management`
- ❌ `/var/log/teeth-management/restore`

#### Added Actual Source Code Paths
All scripts now reference the **single source directory** for GitHub synchronization:

**backup.sh (lines 25-32)**
```bash
SOURCE_ROOT_PATH="$HOME/Teeth-Management-System"
BACKEND_PATH="${SOURCE_ROOT_PATH}/Backend"
FRONTEND_PATH="${SOURCE_ROOT_PATH}/Thoutha-Website"
AI_CHATBOT_PATH="${SOURCE_ROOT_PATH}/Ai-chatbot"
NOTIFICATIONS_PATH="${SOURCE_ROOT_PATH}/Notifications"
OTP_PATH="${SOURCE_ROOT_PATH}/OTP"
LOG_PATH="${SOURCE_ROOT_PATH}/logs"
```

**restore.sh (lines 25-32)** - Identical path configuration

**Key Paths in Use**:
| Component | Path | Purpose |
|-----------|------|---------|
| Source Root | `$HOME/Teeth-Management-System` | GitHub-synced code |
| Backend | `Backend/` | Spring Boot Maven project |
| Frontend | `Thoutha-Website/` | React/Vite source |
| AI Chatbot | `Ai-chatbot/` | FastAPI service |
| Notifications | `Notifications/` | Firebase service |
| OTP Service | `OTP/` | WhatsApp OTP service |
| Logs | `logs/` | astart-managed logs |

---

### 2. **Backup Infrastructure Changes**

#### setup.sh Modifications (lines 230-265)

**Removed:**
- Application directory creation for `/var/apps/` and `/etc/teeth-management` (non-existent)

**Added:**
- Backup directory structure creation under `/backup`:
  - `/backup/metadata`
  - `/backup/database`
  - `/backup/files`
  - `/backup/logs`
- Validation and creation of `$HOME/Teeth-Management-System/logs` (for astart logging)

---

### 3. **Restore Log Destination**

#### restore.sh (line 43)
**Before:**
```bash
RESTORE_LOG_DIR="/var/log/teeth-management/restore"
```

**After:**
```bash
RESTORE_LOG_DIR="${LOG_PATH}/restore"
# Expands to: $HOME/Teeth-Management-System/logs/restore
```

**Rationale**: All logs are now managed by the astart script in a single consistent location.

---

## What's Being Backed Up

### File System Backups
The backup.sh script now backs up (in order of execution):
1. **Apache Configuration** → `apache2_config_TIMESTAMP.tar.gz`
2. **Deployed Frontend** → `webui_files_TIMESTAMP.tar.gz` (from `/var/www/html`)
3. **SSL Certificates** → `ssl_certificates_TIMESTAMP.tar.gz`
4. **Java Installation** → `java_installation_TIMESTAMP.tar.gz`
5. **Source Code** → `teeth_management_source_TIMESTAMP.tar.gz` (NEW - entire `$HOME/Teeth-Management-System`)
6. **Tomcat** (if present) → `tomcat_installation_TIMESTAMP.tar.gz`
7. **System Configuration** → `system_config_TIMESTAMP.tar.gz` (network, host, sudoers, SSH, cron, etc.)

### Database Backups
- **Oracle XE Full Database Export** via Data Pump (`expdp`)
  - Exported to: `/backup/database/tms_full_TIMESTAMP_*.dmp`
  - Log file: `/backup/database/tms_export_TIMESTAMP.log`
  - Password hashes and data integrity fully preserved

### Version Metadata
- Complete system and application version capture before backup begins
- Stored in: `/backup/metadata/versions_TIMESTAMP.txt`
- Used during restore for version verification and mismatch detection

---

## What's Being Restored

The restore.sh script restores in the following order:
1. **Version verification** - Checks backup manifest and system versions
2. **File system restoration** - Extracts all backed-up directories (same list as backup)
3. **Configuration restoration** - Applies system config files (with review step)
4. **Oracle database restoration** - Imports full database backup via Data Pump (`impdp`)
5. **Post-restore validation** - Verifies all components

---

## Unchanged Components

The following paths remain unchanged (system dependencies):
- ✅ `/etc/apache2` - Apache configuration
- ✅ `/var/www/html` - Deployed frontend (updated via astart -u)
- ✅ `/etc/ssl` - SSL certificates
- ✅ `/usr/lib/jvm/java-17-openjdk-amd64` - Java installation
- ✅ `/opt/tomcat` - Tomcat (if installed)
- ✅ `/opt/oracle/product/21c/dbhomeXE` - Oracle XE

---

## Alignment with astart Script

The updated paths now perfectly match the astart service launcher:

**From astart lines 60-73:**
```bash
core_path="$HOME/Teeth-Management-System/Ai-chatbot"
webui_path="$HOME/Teeth-Management-System/Thoutha-Website"
backend_path="$HOME/Teeth-Management-System/Backend"
notification_path="$HOME/Teeth-Management-System/Notifications"
LOG_DIR="$HOME/Teeth-Management-System/logs"
PID_DIR="$LOG_DIR/pids"
otp_dir="$HOME/Teeth-Management-System/OTP"
password_reset_dir="$HOME/Teeth-Management-System"
```

All these paths are now:
- ✅ Referenced in backup/restore scripts
- ✅ Properly included in source code backups
- ✅ Restored to correct locations on new systems
- ✅ Logs directory preserved for astart operation

---

## Testing Checklist

Before using in production, verify:
- [ ] `sudo bash setup.sh` completes without errors
- [ ] `/backup` directory structure exists with proper permissions
- [ ] `$HOME/Teeth-Management-System/logs` directory created
- [ ] `bash backup.sh` creates complete backup in `/backup`
- [ ] Backup manifest includes all directories
- [ ] Oracle Data Pump export files are present in `/backup/database/`
- [ ] `bash restore.sh /backup` successfully restores all files
- [ ] Services restart properly after restore: `astart -w`
- [ ] Database queries work post-restore: `sqlplus -l sys/password as sysdba`
- [ ] Frontend deployed to `/var/www/html` is accessible

---

## File Modifications Summary

| File | Changes | Lines |
|------|---------|-------|
| backup.sh | Updated paths, removed non-existent dirs | 20-32 |
| restore.sh | Updated paths, changed log directory | 20-32, 43 |
| setup.sh | Removed app dirs, added backup dirs, updated log location | 210-230, 231-265 |

---

## Next Steps

1. **Run Setup**: `sudo bash backup/setup.sh`
2. **Verify Installation**: Check `/backup` directory structure
3. **Run First Backup**: `bash backup/backup.sh`
4. **Test Restore**: Set up test system and run `bash backup/restore.sh /path/to/backup`
5. **Monitor Logs**: Check backup/restore logs in appropriate directories

---

## Questions or Issues?

All paths in these scripts now match:
- ✅ Actual system structure (astart-verified)
- ✅ GitHub sync directory (`$HOME/Teeth-Management-System`)
- ✅ Current logging model (astart-managed)
- ✅ Oracle XE installation location (`/opt/oracle/product/21c/dbhomeXE`)

Scripts are ready for testing and production deployment.
