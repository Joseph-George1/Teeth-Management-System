# Environment Variable Consolidation - Master .env Implementation

## Overview
This document summarizes the consolidation of all configuration from scattered locations into a single master `.env` file at the project root. This makes the project easier to configure, deploy, and maintain.

## Master .env File Location
- **Primary:** `$HOME/Teeth-Management-System/.env` (project root)
- **Template:** `.env.example` (used by install.sh for new installations)

---

## Configuration Sections in Master .env

### 1. DATABASE CONFIGURATION
All database connection details are consolidated under a single format:
```
DB_URL=jdbc:oracle:thin:@localhost:1521/orclpdb
DB_USERNAME=hr
DB_PASSWORD=hr
ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
DB_HOST=localhost
DB_PORT=1521
DB_ORACLE_SID=XE
```

**Used by:**
- Backend (Spring Boot): `--spring.datasource.url`
- Notification Service: SQLAlchemy `oracle+oracledb://` URL
- forgetpassword.py: oracledb.connect() with parsed DSN
- backup/backup.sh: sqlplus connections
- backup/restore.sh: SYSDBA restore operations
- astart: Available for all services

### 2. API SERVICE PORTS
Centralized port configuration for all microservices:
```
WEB_UI_PORT=5173            # Vite frontend
BACKEND_PORT=8080           # Spring Boot backend
API_PORT=5010               # Flask AI API
LOGIN_API_PORT=5000         # Login service
OTP_PORT=8000               # OTP service
PROXY_PORT=5173             # CORS proxy
FORGET_PASSWORD_PORT=7000   # Password reset
NOTIFICATION_PORT=9000      # Firebase notifications
DASHBOARD_PORT=6500         # Admin dashboard
```

**Used by:**
- astart: Service launcher (all ports)
- service_monitor.sh: Health checks on configured ports
- admin_dashboard.py: DASHBOARD_PORT
- proxy_server.py: PROXY_PORT
- All services: Available for discovery

### 3. BACKEND COMMUNICATION URLs
Inter-service URLs for development and testing:
```
BACKEND_URL=http://localhost:8080
AI_URL=http://127.0.0.1:5010
OTP_URL=http://127.0.0.1:8000
PROXY_URL=http://127.0.0.1:5173
OTP_SERVICE_URL=http://127.0.0.1:8000
```

**Used by:**
- admin_dashboard.py: API calls to backend, AI, OTP
- forgetpassword.py: OTP service integration
- proxy_server.py: Backend URL routing
- service_monitor.sh: Health check endpoints

### 4. BACKUP CONFIGURATION
System backup paths and retention:
```
BACKUP_ROOT_PATH=/backup
BACKUP_RETENTION_DAYS=7
```

**Used by:**
- backup/backup.sh: Database and system backups
- backup/restore.sh: Restore operations

### 5. DISCORD CONFIGURATION
Discord bot and webhook settings:
```
DISCORD_TOKEN=your-discord-bot-token-here
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
ALLOWED_USER_IDS=1234567890,9876543210
```

**Used by:**
- bot.py: Discord bot authentication
- service_monitor.sh: Discord notifications
- astart: Bot launcher

### 6. FIREBASE CONFIGURATION
Firebase credentials for push notifications:
```
FIREBASE_SERVICE_ACCOUNT_JSON=/path/to/firebase-service-account.json
FIREBASE_KEY_PATH=./Notification/firebase-key.json
```

**Used by:**
- Notification/config.py: Firebase app initialization
- Notification service: FCM push notifications

### 7. WHATSAPP CONFIGURATION (WAHA API)
WhatsApp integration via WAHA HTTP API:
```
WAHA_API_URL=http://127.0.0.1:3000
WAHA_API_KEY=your-api-key-here
WAHA_SESSION=default
WHATSAPP_PHONES=201226191421 201097727531
```

**Used by:**
- service_monitor.sh: WhatsApp alerts
- bot.py: WhatsApp integration

### 8. NOTIFICATION SERVICE CONFIGURATION
Notification retry and queue settings:
```
MAX_RETRIES=3
RETRY_BACKOFF_MULTIPLIER=2.0
INITIAL_RETRY_DELAY_MS=1000
QUEUE_CHECK_INTERVAL=30
TEMPLATE_CACHE_TTL=300
MAX_DEVICES_PER_USER=5
NOTIFICATION_ENVIRONMENT=production
```

**Used by:**
- Notification/config.py: NOTIFICATION_CONFIG dictionary
- Notification service: Retry logic and queue processing

### 9. EMAIL CONFIGURATION (SMTP)
Email delivery via SMTP server:
```
ENABLE_EMAIL=false
SMTP_SERVER=smtp.gmail.com
SMTP_PORT=587
SMTP_USE_TLS=true
SMTP_USE_SSL=false
SENDER_EMAIL=noreply@dentalsystem.com
SENDER_PASSWORD=your-app-password-here
```

**Used by:**
- Notification/config.py: EmailConfig class
- Email notification system

### 10. GOOGLE API CONFIGURATION
Google APIs for AI and services:
```
GOOGLE_API_KEY=your-google-api-key-here
```

**Used by:**
- AI-chatbot: Generative AI features
- Notification service: Optional Google integrations

### 11. ADMIN DASHBOARD CONFIGURATION
Admin panel security and obfuscation:
```
SECRET_KEY=your-fixed-secret-key-here
ADMIN_PREFIX=/api/tms-mng-x7k2p9q3
```

**Used by:**
- admin_dashboard.py: Session persistence and route protection

### 12. LOGGING CONFIGURATION
Centralized logging paths and levels:
```
LOG_DIR=$HOME/Teeth-Management-System/logs
LOG_LEVEL=INFO
LOG_FILE=$HOME/Teeth-Management-System/logs/application.log
```

**Used by:**
- astart: Process logging
- service_monitor.sh: Service monitoring logs
- Notification/config.py: Application logging
- bot.py: Discord bot logging
- All Python services: Application logging

---

## Files Modified

### .env.example
**Status:** ✅ CREATED/UPDATED
- Comprehensive template with 130+ lines
- Organized into 12 configuration sections
- Clear documentation for each variable
- Defaults that work for development
- Production notes for security-sensitive variables

### install.sh
**Status:** ✅ MODIFIED
- **setup_env_file():** Enhanced with interactive prompts
  - Checks for existing `.env` file
  - Copies from `.env.example` if available
  - Interactive update of DB credentials
  - Fallback template creation with all variables
- **show_post_install():** Updated with comprehensive configuration reference
  - Lists all 50+ configuration options
  - Organized by category in formatted table
  - References .env.example for details

### forgetpassword.py
**Status:** ✅ VERIFIED COMPLIANT
- Loads `.env` from project root
- Reads DB_URL, DB_USERNAME, DB_PASSWORD
- Parses JDBC URLs to extract connection parameters
- Uses oracledb.connect() with parsed DSN

### backup/backup.sh
**Status:** ✅ VERIFIED COMPLIANT
- Sources `.env` from parent directory
- Reads all database configuration variables
- Parses DB_URL JDBC format
- Uses for sqlplus backup operations

### backup/restore.sh
**Status:** ✅ VERIFIED COMPLIANT
- Sources `.env` from parent directory
- Reads database and backup configuration
- Supports dual accounts (DB_USERNAME and DB_RESTORE_USER)
- Uses ORACLE_HOME and DB_* variables

### Notification/config.py
**Status:** ✅ FULLY UPDATED
- Loads from `.env` via `load_dotenv()`
- Reads all notification service configuration
- MAX_RETRIES, RETRY_BACKOFF_MULTIPLIER, INITIAL_RETRY_DELAY_MS
- QUEUE_CHECK_INTERVAL, TEMPLATE_CACHE_TTL
- MAX_DEVICES_PER_USER, NOTIFICATION_ENVIRONMENT
- Firebase, Email, and Logging configuration
- Updated environment variable name: NOTIFICATION_ENVIRONMENT

### admin_dashboard.py
**Status:** ✅ VERIFIED COMPLIANT
- Reads from os.getenv() for all configuration
- BACKEND_URL, AI_URL, OTP_URL, PROXY_URL
- DASHBOARD_PORT, SECRET_KEY, ADMIN_PREFIX
- Maintains session persistence across restarts
- No changes needed (already correctly implemented)

### proxy_server.py
**Status:** ✅ VERIFIED COMPLIANT
- Reads from os.getenv() for all configuration
- BACKEND_URL, PROXY_PORT
- No changes needed (already correctly implemented)

### Ai-chatbot/api.py
**Status:** ✅ VERIFIED COMPLIANT
- Calls `load_dotenv()` to load .env
- Uses os.getenv() for configuration
- Already correctly implemented

### bot.py
**Status:** ✅ FULLY UPDATED
- Added `from dotenv import load_dotenv`
- Explicit .env file loading from project root
- Updated parse_log_paths() to read from .env first
- Fallback to astart file parsing for backward compatibility
- Reads DISCORD_TOKEN from environment variables

### astart
**Status:** ✅ FULLY UPDATED
- Loads `.env` from `$HOME/Teeth-Management-System/.env`
- Reads database configuration (DB_URL, DB_USERNAME, DB_PASSWORD)
- Reads all port configuration variables
- Now reads LOG_DIR and LOG_LEVEL from .env
- Falls back to defaults if .env not found

### service_monitor.sh
**Status:** ✅ VERIFIED COMPLIANT
- Sources `.env` from project root
- Reads all notification configuration
- DISCORD_WEBHOOK_URL, WAHA_API_URL, WAHA_API_KEY
- WAHA_SESSION, WHATSAPP_PHONES
- Supports both space-separated strings and arrays
- No changes needed (already correctly implemented)

---

## Variable Cross-Reference

### Python Services Environment Variables
| Variable | Service | Usage |
|----------|---------|-------|
| DB_URL | All | Database connection |
| DB_USERNAME | All | Database user |
| DB_PASSWORD | All | Database password |
| BACKEND_URL | admin_dashboard, proxy_server | API routing |
| AI_URL | admin_dashboard | AI chatbot API |
| OTP_URL | admin_dashboard | OTP service |
| PROXY_URL | admin_dashboard | Web UI proxy |
| DASHBOARD_PORT | admin_dashboard | Admin panel port |
| NOTIFICATION_PORT | Notification | Service port |
| LOG_DIR | All | Log directory |
| LOG_LEVEL | All | Logging level |
| LOG_FILE | All | Log file path |
| FIREBASE_SERVICE_ACCOUNT_JSON | Notification | Firebase credentials |
| ENABLE_EMAIL | Notification | Email activation |
| SMTP_SERVER | Notification | Email server |
| SMTP_PORT | Notification | Email port |
| SENDER_EMAIL | Notification | Sender address |
| SENDER_PASSWORD | Notification | Email password |
| GOOGLE_API_KEY | AI-chatbot | Google APIs |

### Bash Scripts Environment Variables
| Variable | Script | Usage |
|----------|--------|-------|
| DB_URL | backup.sh, restore.sh | Database connection |
| DB_USERNAME | backup.sh, restore.sh | Backup user |
| DB_PASSWORD | backup.sh, restore.sh | Backup password |
| ORACLE_HOME | backup.sh, restore.sh | Oracle installation |
| DB_HOST | backup.sh, restore.sh | Database host |
| DB_PORT | backup.sh, restore.sh | Database port |
| BACKUP_ROOT_PATH | backup.sh, restore.sh | Backup location |
| DISCORD_WEBHOOK_URL | service_monitor.sh | Discord alerts |
| WAHA_API_URL | service_monitor.sh | WhatsApp API |
| WAHA_API_KEY | service_monitor.sh | WhatsApp API key |
| WAHA_SESSION | service_monitor.sh | WhatsApp session |
| WHATSAPP_PHONES | service_monitor.sh | Alert recipients |
| LOG_DIR | astart, bot.py | Log directory |

---

## Installation & Deployment

### First-Time Installation
1. Run `./install.sh`
2. Script automatically:
   - Copies `.env.example` to `.env`
   - Prompts for database credentials
   - Updates all necessary values
   - Sets up logs directory

### Environment Setup
1. Review `.env` file for all configuration
2. Update security-sensitive values:
   - DB_PASSWORD
   - DISCORD_TOKEN
   - WAHA_API_KEY
   - SENDER_PASSWORD
   - GOOGLE_API_KEY
   - FIREBASE_SERVICE_ACCOUNT_JSON
3. Ensure paths match your system:
   - ORACLE_HOME
   - BACKUP_ROOT_PATH
   - LOG_DIR

### Service Launch
All services automatically read from master `.env`:
```bash
./astart              # Launches all services
./service_monitor.sh  # Monitors and alerts
```

---

## Configuration Loading Order

### Python Services (load_dotenv pattern)
1. Check for `.env` in project root
2. Load environment variables
3. Fall back to hardcoded defaults

### Shell Scripts (source pattern)
1. Check for `.env` at `$HOME/Teeth-Management-System/.env`
2. Export all variables using `set -a; source .env; set +a`
3. Use bash parameter expansion for defaults: `${VAR:-default}`

### Spring Boot Backend (system properties)
1. Read from environment variables
2. Can also use `--spring.datasource.url` command-line override

---

## Security Considerations

### Never Commit .env
- Already in `.gitignore`
- Only `.env.example` is version-controlled
- Credentials remain local to each environment

### Production Recommendations
1. Set fixed `SECRET_KEY` for admin dashboard
2. Use strong `SENDER_PASSWORD` for email
3. Restrict `ALLOWED_USER_IDS` for Discord bot
4. Use secure API keys for WAHA and Google
5. Enable `SMTP_USE_TLS` for email security
6. Keep FIREBASE credentials file secure
7. Limit `WHATSAPP_PHONES` to necessary recipients

---

## Troubleshooting

### Services Not Reading Configuration
1. Verify `.env` exists at project root
2. Check file permissions: `ls -la .env`
3. Verify variable names match exactly (case-sensitive)
4. Test with: `source .env && echo $DB_USERNAME`

### Database Connection Issues
- Verify DB_URL format: `jdbc:oracle:thin:@host:port/service_name`
- Check DB_HOST and DB_PORT separately
- Confirm DB_USERNAME and DB_PASSWORD
- Test with sqlplus: `sqlplus DB_USERNAME/DB_PASSWORD@DB_HOST:DB_PORT/DB_ORACLE_SID`

### Service Monitor Not Alerting
1. Verify DISCORD_WEBHOOK_URL is correct
2. Verify WHATSAPP_PHONES format (no + prefix, space-separated)
3. Check WAHA_API_KEY and WAHA_API_URL
4. Verify LOG_DIR exists and is writable

### Notification Service Issues
1. Verify FIREBASE_SERVICE_ACCOUNT_JSON path exists
2. Check MAX_RETRIES and retry settings
3. Verify SMTP settings if email enabled
4. Check LOG_LEVEL for debugging

---

## Summary of Changes

✅ **All configuration is now centralized** in the master `.env` file
✅ **All services read from the same source** (root .env)
✅ **Installation script updated** with comprehensive .env setup
✅ **All Python services** properly load environment variables
✅ **All shell scripts** properly source .env
✅ **Backward compatibility maintained** with fallback defaults
✅ **Documentation complete** with variable references

---

## Next Steps

1. Test new installation with `./install.sh`
2. Verify all services start with `./astart`
3. Monitor services with `./service_monitor.sh`
4. Document any deployment-specific variables
5. Update production `.env` with real credentials
