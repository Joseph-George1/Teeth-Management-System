# Teeth Management System - Backup & Restore Context Map

## Complete Backup/Restore Flow

### 1. FILE SYSTEM BACKUPS

| Component | Source Path | Backup File | Backup Method | Restore Destination | Notes |
|-----------|-------------|-------------|----------------|-------------------|-------|
| **Apache Configuration** | `/etc/apache2` | `/backup/files/apache2_config_TIMESTAMP.tar.gz` | tar -czf | `/etc/apache2` | Web server config, vhosts, modules |
| **Deployed Frontend** | `/var/www/html` | `/backup/files/webui_files_TIMESTAMP.tar.gz` | tar -czf | `/var/www/html` | Compiled React/Vite build (from `npm run build`) |
| **SSL Certificates** | `/etc/ssl` | `/backup/files/ssl_certificates_TIMESTAMP.tar.gz` | tar -czf | `/etc/ssl` | HTTPS certificates and keys |
| **Java Installation** | `/usr/lib/jvm/java-17-openjdk-amd64` | `/backup/files/java_installation_TIMESTAMP.tar.gz` | tar -czf | `/usr/lib/jvm/java-17-openjdk-amd64` | OpenJDK 17 runtime/compiler |
| **Source Code** | `$HOME/Teeth-Management-System` | `/backup/files/teeth_management_source_TIMESTAMP.tar.gz` | tar -czf | `$HOME/Teeth-Management-System` | ALL source code: Backend, Frontend, AI, Notifications, OTP |
| **Tomcat Server** | `/opt/tomcat` | `/backup/files/tomcat_installation_TIMESTAMP.tar.gz` | tar -czf | `/opt/tomcat` | Application server (if installed) |
| **System Config Files** | Multiple (see below) | `/backup/files/system_config_TIMESTAMP.tar.gz` | tar -czf | Review + Manual Apply | Network, SSH, sudoers, cron, hosts, etc. |

---

### 2. SYSTEM CONFIGURATION FILES (Detailed)

| Config File | Source Path | Backup Destination | Restore Method | Purpose |
|-------------|-------------|-------------------|-----------------|---------|
| Hosts File | `/etc/hosts` | `/backup/files/system_config_*/hosts` | Manual cp | Hostname to IP mapping |
| Hostname | `/etc/hostname` | `/backup/files/system_config_*/hostname` | Manual cp | Server name |
| Network Config | `/etc/network/interfaces` | `/backup/files/system_config_*/interfaces` | Manual cp | Static IP configuration |
| Apache Sites | `/etc/apache2/sites-available` | `/backup/files/system_config_*/sites-available/` | Manual cp | Virtual host definitions |
| Apache Sites Enabled | `/etc/apache2/sites-enabled` | `/backup/files/system_config_*/sites-enabled/` | Manual cp | Enabled vhost symlinks |
| Apache Config | `/etc/apache2/conf-available` | `/backup/files/system_config_*/conf-available/` | Manual cp | Apache modules config |
| Apache Enabled Config | `/etc/apache2/conf-enabled` | `/backup/files/system_config_*/conf-enabled/` | Manual cp | Enabled config symlinks |
| Apache Modules | `/etc/apache2/mods-enabled` | `/backup/files/system_config_*/mods-enabled/` | Manual cp | Enabled module symlinks |
| Root Bashrc | `/root/.bashrc` | `/backup/files/system_config_*/.bashrc` | Manual cp | Root shell configuration |
| Root Bash Profile | `/root/.bash_profile` | `/backup/files/system_config_*/.bash_profile` | Manual cp | Root login shell config |
| Filesystem Table | `/etc/fstab` | `/backup/files/system_config_*/fstab` | Manual cp | Disk mount configuration |
| Sudoers | `/etc/sudoers` | `/backup/files/system_config_*/sudoers` | Manual cp | Sudo permissions (⚠️ CRITICAL) |
| Cron Jobs | `/etc/cron.d` | `/backup/files/system_config_*/cron.d/` | Manual cp | Scheduled tasks |
| Crontab | `/etc/crontab` | `/backup/files/system_config_*/crontab` | Manual cp | System crontab |
| SSH Keys | `/root/.ssh` | `/backup/files/system_config_*/.ssh/` | Manual cp | SSH key authentication |

---

### 3. ORACLE XE DATABASE BACKUP & RESTORE

| Component | Source | Backup Files | Backup Method | Restore Method | Database Integrity |
|-----------|--------|--------------|----------------|-----------------|-------------------|
| **Full Database Export** | Oracle XE Instance (SID: XE) | `/backup/database/tms_full_TIMESTAMP_*.dmp` | `expdp` (Data Pump) | `impdp` (Data Pump) | Full schema, tables, indexes, constraints |
| **Export Log** | Oracle XE Instance | `/backup/database/tms_export_TIMESTAMP.log` | expdp output | Reference during restore | Success/failure details, row counts |
| **Password Hashes** | Oracle users table | Included in DMP file | expdp (full=y) | impdp (full=y) | **PRESERVED UNCHANGED** - No hash modifications |
| **User Data** | All tables | Included in DMP file | expdp (full=y) | impdp (full=y) | All dental records, appointments, user info |
| **Statistics** | Table statistics | **EXCLUDED** from backup | expdp exclude=statistics | Regenerated on restore | Fresh statistics computed post-restore |

**Oracle Configuration:**
- **Instance**: XE (Oracle 21c)
- **User**: sys (with SYSDBA privileges)
- **Home**: `/opt/oracle/product/21c/dbhomeXE`
- **Data Pump Dir**: `/opt/oracle/admin/xe/dpdump`
- **Backup Retention**: Full backup of entire database instance

---

### 4. VERSION METADATA & MANIFEST

| Item | Source | Backup Location | Purpose |
|------|--------|-----------------|---------|
| **Version Manifest** | System commands | `/backup/metadata/versions_TIMESTAMP.txt` | Document all installed versions |
| **Backup Manifest** | Backup summary | `/backup/metadata/manifest_TIMESTAMP.txt` | List of all backed up files and sizes |
| **OS Version** | `lsb_release -a` | versions_*.txt | Ubuntu version info |
| **Java Version** | `java -version` | versions_*.txt | OpenJDK 17 version |
| **Maven Version** | `mvn -v` | versions_*.txt | Maven 3.8.7 version |
| **Node.js Version** | `node --version` | versions_*.txt | Node.js v20.x version |
| **NPM Version** | `npm --version` | versions_*.txt | npm version |
| **Oracle Version** | `sqlplus -version` | versions_*.txt | Oracle 21c version |
| **Python Version** | `python3 --version` | versions_*.txt | Python 3.x version |
| **OpenSSL Version** | `openssl version` | versions_*.txt | OpenSSL crypto library version |
| **Backend Version** | `pom.xml` | versions_*.txt | Spring Boot version from pom.xml |
| **Frontend Version** | `package.json` | versions_*.txt | React/Vite version from package.json |

---

### 5. SOURCE CODE STRUCTURE (What Gets Backed Up)

Inside `/backup/files/teeth_management_source_TIMESTAMP.tar.gz`:

```
Teeth-Management-System/
├── Backend/
│   ├── src/
│   │   ├── main/java/     # Spring Boot application code
│   │   └── main/resources/
│   ├── target/            # Maven build output (included)
│   ├── pom.xml           # Maven dependencies & versions
│   └── mvnw, mvnw.cmd    # Maven wrapper scripts
│
├── Thoutha-Website/
│   ├── src/              # React source components
│   ├── public/           # Static assets
│   ├── dist/             # Built frontend (if exists)
│   ├── package.json      # npm dependencies
│   └── vite.config.js    # Vite build configuration
│
├── Ai-chatbot/
│   ├── api.py           # FastAPI backend
│   ├── questions.json   # Chatbot knowledge base
│   └── requirements.txt # Python dependencies
│
├── Notifications/
│   ├── main.py          # Firebase notification service
│   ├── config/          # Configuration files
│   ├── models/          # Database models
│   ├── routes/          # API endpoints
│   ├── services/        # Business logic
│   ├── security/        # Authentication
│   ├── utils/           # Utilities
│   └── requirements.txt # Python dependencies
│
├── OTP/
│   ├── OTP_W.py         # WhatsApp OTP service
│   └── requirements.txt # Python dependencies
│
├── logs/
│   ├── astart_activity.log      # Service launcher activity log
│   ├── process_logs/            # Individual service logs
│   └── pids/                    # Process ID files
│
├── Database/
│   ├── migration_oracle_xe.sql  # Schema migration scripts
│   ├── notification_tables_migration.sql
│   └── *.sql                    # Other migrations
│
├── Docs/
│   ├── Notifications/           # Notification documentation
│   ├── Database/                # Database docs
│   └── Backend/                 # Backend docs
│
├── astart                       # Service launcher script
├── install.sh                   # Installation script
├── proxy_server.py             # CORS proxy
├── forgetpassword.py           # Password reset service
├── admin_dashboard.py          # Admin dashboard
├── requirements.txt            # Root Python dependencies
├── LICENSE                     # License file
└── README.md                   # Documentation
```

---

### 6. LOGS DIRECTORY STRUCTURE (What Gets Backed Up)

Inside source code backup, `/logs/` contains:

| Directory | Content | Purpose | Backup Included |
|-----------|---------|---------|-----------------|
| `astart_activity.log` | Service start/stop records | Activity audit trail | ✅ Yes |
| `process_logs/` | Individual service logs | Debugging & monitoring | ✅ Yes |
| `pids/` | Process ID files | Process tracking | ✅ Yes |

**Note**: These logs are managed by the `astart` script and provide operational history. Backed up for audit/debugging purposes.

---

### 7. DIRECTORY BACKUP SIZE ESTIMATES

| Component | Typical Size | Compression Ratio |
|-----------|-------------|-------------------|
| Apache config | ~10 MB | 2:1 |
| Deployed frontend | 5-50 MB | 3:1 |
| SSL certificates | ~1 MB | 2:1 |
| Java installation | 200+ MB | 5:1 |
| **Source code** | 500 MB - 2 GB | 10:1 |
| Tomcat (if present) | 150+ MB | 4:1 |
| System config files | ~20 MB | 3:1 |
| **TOTAL FILES (compressed)** | ~100-300 MB | Variable |
| **Oracle Database** | 1-10 GB+ | 1:1 |
| **TOTAL BACKUP** | ~1-10+ GB | Variable |

---

### 8. RESTORE SEQUENCE

**Order matters for proper restoration:**

1. **Verify Backup** → Check backup integrity and version manifest
2. **Verify System Versions** → Check if installed versions match backup versions
3. **Stop Services** → `astart -s` (all services via astart)
4. **Restore Files** (in order):
   - Java installation
   - Apache configuration
   - SSL certificates
   - Source code → `$HOME/Teeth-Management-System`
   - Tomcat (if applicable)
   - System configuration (with review)
5. **Restore Database** → Oracle Data Pump import
6. **Restore Logs** → Extracted as part of source code
7. **Rebuild Frontend** → `cd Thoutha-Website && npm install && npm run build`
8. **Deploy Frontend** → `astart -u` (git pull + build + copy to `/var/www/html`)
9. **Restart Services** → `astart -w` (whole system)
10. **Verify** → Check logs and test endpoints

---

### 9. CRITICAL PATHS REFERENCE

| Usage Context | Path |
|---------------|------|
| Source root | `$HOME/Teeth-Management-System` |
| Backend source | `$HOME/Teeth-Management-System/Backend` |
| Frontend source | `$HOME/Teeth-Management-System/Thoutha-Website` |
| Deployed frontend | `/var/www/html` |
| Deployed backend | Via `mvn spring-boot:run` from source |
| Service logs | `$HOME/Teeth-Management-System/logs` |
| Backup root | `/backup` |
| Backup metadata | `/backup/metadata` |
| Backup database files | `/backup/database` |
| Backup file archives | `/backup/files` |
| Backup logs | `/backup/logs` |
| Oracle home | `/opt/oracle/product/21c/dbhomeXE` |
| Java home | `/usr/lib/jvm/java-17-openjdk-amd64` |

---

### 10. DATA INTEGRITY GUARANTEES

| Data Type | Backup Method | Integrity Guarantee | Notes |
|-----------|----------------|-------------------|-------|
| **Password Hashes** | Oracle expdp full=y | ✅ 100% Preserved | No modifications, raw binary export |
| **User Data** | Oracle expdp full=y | ✅ 100% Preserved | All tables exported with constraints |
| **Database Constraints** | Oracle expdp | ✅ Included | Foreign keys, unique constraints restored |
| **Database Indexes** | Oracle expdp | ✅ Included | Index structures recreated on restore |
| **File Permissions** | tar -czf | ⚠️ Partial | Permissions preserved where possible |
| **File Ownership** | tar -czf | ⚠️ Partial | May require chown after restore |
| **Symlinks** | tar -czf | ✅ Preserved | As symlinks in archive |
| **Application Config** | tar -czf | ✅ Preserved | Including API keys, DB credentials |

---

### 11. BACKUP COMMAND EXAMPLES

```bash
# Full backup (from backup directory)
bash backup.sh

# What happens inside:
# 1. Creates version manifest
# 2. Exports Oracle database with expdp
# 3. Tars all system directories
# 4. Compresses to /backup/files/
# 5. Creates backup manifest
# 6. Generates checksums

# Output locations:
# /backup/metadata/versions_*.txt
# /backup/metadata/manifest_*.txt
# /backup/database/tms_full_*.dmp
# /backup/database/tms_export_*.log
# /backup/files/apache2_config_*.tar.gz
# /backup/files/webui_files_*.tar.gz
# /backup/files/ssl_certificates_*.tar.gz
# /backup/files/java_installation_*.tar.gz
# /backup/files/teeth_management_source_*.tar.gz
# /backup/files/tomcat_installation_*.tar.gz
# /backup/files/system_config_*.tar.gz
```

---

### 12. RESTORE COMMAND EXAMPLES

```bash
# Restore from /backup directory
bash restore.sh /backup

# What happens inside:
# 1. Verifies backup integrity
# 2. Checks version mismatches
# 3. Extracts all file system archives
# 4. Reviews & applies config files
# 5. Imports Oracle database with impdp
# 6. Validates restoration
# 7. Logs all actions

# Log location:
# $HOME/Teeth-Management-System/logs/restore/restore_*.log
# $HOME/Teeth-Management-System/logs/restore/version_mismatches_*.txt
```

---

## Summary Matrix

| Phase | What | Source | Destination | Method |
|-------|------|--------|-------------|--------|
| **PRE-BACKUP** | Version capture | System commands | `/backup/metadata/versions_*.txt` | Bash commands |
| **FILE BACKUP** | Config & code | `/etc/`, `/usr/`, `$HOME/` | `/backup/files/*.tar.gz` | tar -czf |
| **DB BACKUP** | Full database | Oracle XE instance | `/backup/database/*.dmp` | expdp |
| **MANIFEST** | Backup summary | File listing | `/backup/metadata/manifest_*.txt` | find + du |
| **PRE-RESTORE** | Version check | Backup metadata | Comparison logs | grep + parsing |
| **FILE RESTORE** | All archives | `/backup/files/*.tar.gz` | Original paths | tar -xzf |
| **CONFIG RESTORE** | System files | `/backup/files/system_config_*.tar.gz` | `/etc/`, `/root/` | Manual (reviewed) |
| **DB RESTORE** | Full database | `/backup/database/*.dmp` | Oracle XE instance | impdp |
| **VERIFICATION** | Health check | Restored system | Validation logs | Service tests |

---

This map provides complete visibility into what gets backed up, where it's stored, and how it gets restored! 🎯
