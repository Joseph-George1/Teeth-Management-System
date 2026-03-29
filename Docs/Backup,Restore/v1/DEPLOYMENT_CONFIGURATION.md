# DEPLOYMENT & CONFIGURATION GUIDE

## 🎯 Project Structure Overview

```
Teeth-Management-System/
├── Backend/                          # Java Spring Boot application
│   ├── pom.xml                      # Maven configuration (Spring Boot 3.5.7, Java 17)
│   ├── src/
│   └── target/                      # Built JAR files
│
├── Thoutha-Website/                 # React/Vite frontend
│   ├── package.json                 # Node.js dependencies
│   ├── vite.config.js               # Vite build config
│   ├── src/                         # React components
│   └── dist/                        # Built static files
│
├── Ai-chatbot/                      # Python FastAPI chatbot service
│   ├── api.py                       # FastAPI application
│   ├── ai_client.py                 # AI service client
│   └── requirements.txt             # Python dependencies
│
├── Notifications/                   # Python notification service
│   ├── main.py                      # Main service
│   ├── requirements.txt             # Python dependencies
│   └── config/                      # Configuration
│
├── Database/                        # Database migration scripts
│   ├── migration_oracle_xe.sql     # Oracle schema creation
│   ├── notification_tables_migration.sql
│   └── MIGRATION_QUICK_REFERENCE.txt
│
├── OTP/                            # One-time password service
│   └── OTP_W.py
│
├── backup/                         # Backup & restore scripts
│   ├── backup.sh                   # Complete backup script (NEW)
│   ├── restore.sh                  # Complete restore script (NEW)
│   ├── setup.sh                    # Setup helper (NEW)
│   ├── BACKUP_RESTORE_GUIDE.md     # Full documentation (NEW)
│   ├── DATABASE_BACKUP_DETAILS.md  # Technical details (NEW)
│   └── QUICK_REFERENCE.txt         # Quick reference (NEW)
│
└── Docs/                           # Documentation
    ├── Backend/
    ├── Database/
    │   ├── MIGRATION_README.md
    │   └── SCHEMA_COMPARISON.md
    └── Notifications/
```

---

## 🗄️ Database Configuration

### Oracle XE Database Setup

#### Tables and Schemas

```sql
-- Core Application Schemas
CREATE USER TEETH_MGMT IDENTIFIED BY password;
GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE PROCEDURE TO TEETH_MGMT;

-- Tables (from Database/migration_oracle_xe.sql):
-- - USERS (patient accounts, password hashes - bcrypt)
-- - APPOINTMENTS (booking records)
-- - PATIENTS (patient profiles)
-- - DOCTORS (doctor profiles)
-- - TREATMENTS (treatment records)
-- - PAYMENTS (payment transactions)
-- - NOTIFICATIONS (notification log)
-- - OTP_VERIFICATION (OTP records)
-- - AUDIT_LOG (system audit trail)
```

#### Connection Parameters

```
Database: Oracle XE 21c
Port: 1521
SID: XE
Hostname: localhost (production server)
Admin User: sys (password from environment)
App User: TEETH_MGMT (read/write permissions)
```

#### Backup Strategy for Database

```
Tool: Oracle Data Pump (expdp/impdp)
Scope: FULL=Y (all schemas and objects)
Compression: MEDIUM
Parallel: 4 workers
Exclude: STATISTICS (rebuilt on import)
Directory: /u01/app/oracle/admin/xe/dpdump/

What's backed up:
- All tables with data
- All indexes
- All stored procedures
- All triggers
- All constraints
- Parameter files (spfile)
- Password file

Password hashes:
- Stored as bcrypt in USERS.PASSWORD_HASH column
- NEVER modified during backup/restore
- Data integrity preserved 100%
```

---

## 🚀 Backend Deployment (Spring Boot 3.5.7)

### Architecture

```
Spring Boot Application
├── Controllers (REST API endpoints)
├── Services (Business logic)
├── Repositories (JPA/ORM to Oracle)
├── Models (Entity classes)
├── Config (Spring configuration)
└── Resources (application.properties)
```

### Java Configuration

```properties
# application.properties (Backend/src/main/resources/)

# Server
server.port=8080
server.servlet.context-path=/api

# Oracle Database Connection
spring.datasource.url=jdbc:oracle:thin:@localhost:1521:XE
spring.datasource.username=TEETH_MGMT
spring.datasource.password=your_password
spring.datasource.driver-class-name=oracle.jdbc.driver.OracleDriver

# JPA Configuration
spring.jpa.database-platform=org.hibernate.dialect.OracleDialect
spring.jpa.hibernate.ddl-auto=validate
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.generate_statistics=false

# Logging
logging.level.root=INFO
logging.level.com.spring.boot=DEBUG
logging.file=/var/log/teeth-management/backend.log
```

### Build Process

```bash
# Local Development Build
cd Backend
mvn clean install

# Production Build with Optimization
mvn clean package -DskipTests -Pproduction

# Run Application
java -jar target/GraduationProject1-0.0.1-SNAPSHOT.jar

# Or via Tomcat
cp target/GraduationProject1-0.0.1-SNAPSHOT.jar /opt/tomcat/webapps/ROOT.war
systemctl restart tomcat
```

### Deployment Configuration

```
Deployment Method: Tomcat Application Server
Java Version: 17 (OpenJDK)
JVM Memory: -Xms2G -Xmx4G (production)
Port: 8080 (internal, proxied via Apache)
Thread Pool: Default Tomcat settings
Connection Pool: HikariCP (10-20 connections)
```

---

## 🎨 Frontend Deployment (React 18.2 + Vite)

### Architecture

```
React + Vite Application
├── Components (UI components)
│   ├── ChatBotIcon
│   ├── NavBar
│   ├── Footer
│   └── ...other components
├── Pages (Page components)
├── Services (API calls via Axios)
├── CSS (Tailwind + custom styles)
└── Assets
```

### Node.js Configuration

```json
{
  "name": "thoutha-project",
  "version": "0.0.0",
  "type": "module",
  "engines": {
    "node": "^18.0.0",
    "npm": "^9.0.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint ."
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^7.12.0",
    "axios": "^1.6.0",
    "tailwindcss": "^3.x"
  }
}
```

### Build Process

```bash
# Development
cd Thoutha-Website
npm install
npm run dev          # Runs on http://localhost:5173

# Production Build
npm run build        # Creates dist/ directory

# Preview Built Version
npm run preview

# Deploy to Apache
cp -r dist/* /var/www/html/
systemctl reload apache2
```

### Deployment Configuration

```
Deployment Method: Apache static files
Build Tool: Vite
Node Version: 18.x LTS
npm Version: 9.x
Served from: /var/www/html/
Apache Config: VirtualHost on port 80/443
```

---

## 🔌 AI Chatbot Service (Python + FastAPI)

### Configuration

```
Framework: FastAPI
Port: 8000
Worker Count: 4 (Gunicorn)
Python Version: 3.8+
Dependencies: See requirements.txt
```

### Dependencies

```
# Ai-chatbot/requirements.txt
fastapi
uvicorn[standard]
httpx
pydantic
google-generativeai
python-dotenv
bcrypt
oracledb
```

### Environment Variables

```bash
# .env file
GOOGLE_API_KEY=your_api_key
ORACLE_USER=TEETH_MGMT
ORACLE_PASSWORD=password
ORACLE_HOST=localhost
ORACLE_PORT=1521
ORACLE_SID=XE
```

### Startup

```bash
cd Ai-chatbot
pip install -r requirements.txt
gunicorn -w 4 -b 0.0.0.0:8000 api:app
```

---

## 🔔 Notification Service (Python)

### Configuration

```
Framework: Flask/FastAPI
Port: 5000
Python Version: 3.8+
Dependencies: See requirements.txt
```

### Services Included

```
- Firebase Cloud Messaging (notifications)
- Email notifications
- SMS notifications (if configured)
- In-app notification database storage
```

### Startup

```bash
cd Notifications
pip install -r requirements.txt
python main.py
```

---

## 🌐 Apache 2.4 Web Server Configuration

### VirtualHost Configuration

```apache
# /etc/apache2/sites-available/teeth-management.conf

<VirtualHost *:80>
    ServerName teeth-management.example.com
    ServerAlias www.teeth-management.example.com
    DocumentRoot /var/www/html

    # Redirect HTTP to HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

<VirtualHost *:443>
    ServerName teeth-management.example.com
    ServerAlias www.teeth-management.example.com
    DocumentRoot /var/www/html

    # SSL Configuration
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/teeth-management.crt
    SSLCertificateKeyFile /etc/ssl/private/teeth-management.key
    SSLCertificateChainFile /etc/ssl/certs/chain.crt

    # Enable HTTP/2
    Protocols h2 http/1.1

    # Security Headers
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "strict-origin-when-cross-origin"

    # Proxy to Backend APIs
    ProxyPreserveHost On
    ProxyPass /api/ http://localhost:8080/api/
    ProxyPassReverse /api/ http://localhost:8080/api/

    # Proxy to Chatbot Service
    ProxyPass /chatbot/ http://localhost:8000/
    ProxyPassReverse /chatbot/ http://localhost:8000/

    # Proxy to Notifications
    ProxyPass /notifications/ http://localhost:5000/
    ProxyPassReverse /notifications/ http://localhost:5000/

    # Static Files
    <Directory /var/www/html>
        Options -Indexes
        AllowOverride All
        Require all granted
        
        # Rewrite rules for SPA (React Router)
        RewriteEngine On
        RewriteBase /
        RewriteRule ^index\.html$ - [L]
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule . /index.html [L]
    </Directory>

    # Gzip Compression
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html
        AddOutputFilterByType DEFLATE text/plain
        AddOutputFilterByType DEFLATE text/xml
        AddOutputFilterByType DEFLATE text/css
        AddOutputFilterByType DEFLATE text/javascript
        AddOutputFilterByType DEFLATE application/javascript
        AddOutputFilterByType DEFLATE application/json
    </IfModule>

    # Caching
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresByType image/jpeg "access plus 1 year"
        ExpiresByType image/gif "access plus 1 year"
        ExpiresByType image/png "access plus 1 year"
        ExpiresByType text/css "access plus 1 month"
        ExpiresByType text/javascript "access plus 1 month"
        ExpiresByType application/javascript "access plus 1 month"
    </IfModule>

    # Logging
    CustomLog ${APACHE_LOG_DIR}/teeth-management-access.log combined
    ErrorLog ${APACHE_LOG_DIR}/teeth-management-error.log
    LogLevel warn
</VirtualHost>
```

### Enabled Modules

```bash
a2enmod rewrite           # URL rewriting
a2enmod ssl              # HTTPS/TLS
a2enmod headers          # Custom headers
a2enmod proxy            # Proxy to backend services
a2enmod proxy_http       # HTTP proxy
a2enmod deflate          # Gzip compression
a2enmod expires          # Cache control
a2enmod http2            # HTTP/2 support
```

### Enable Site

```bash
sudo a2ensite teeth-management.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
```

---

## 🐳 Service Management

### System Services

```bash
# Apache Web Server
sudo systemctl start apache2
sudo systemctl stop apache2
sudo systemctl restart apache2
sudo systemctl status apache2
sudo systemctl enable apache2          # Start on boot

# Tomcat Application Server
sudo systemctl start tomcat
sudo systemctl stop tomcat
sudo systemctl restart tomcat
sudo systemctl status tomcat
sudo systemctl enable tomcat

# Oracle Database
sudo systemctl start oracle-xe-21c
sudo systemctl stop oracle-xe-21c
sudo systemctl restart oracle-xe-21c
sudo systemctl status oracle-xe-21c
sudo systemctl enable oracle-xe-21c
```

### Python Services (Background)

```bash
# Chatbot Service
nohup python -m Ai-chatbot.api > /var/log/chatbot.log 2>&1 &

# Notification Service
nohup python Notifications/main.py > /var/log/notifications.log 2>&1 &

# Or use Supervisor/Systemd for production
# See documentation for production setup
```

---

## 📝 Configuration Checklist

### Pre-Deployment

- [ ] Java 17 installed: `java -version`
- [ ] Maven 3.9+ installed: `mvn -v`
- [ ] Node.js 18+ installed: `node -v`
- [ ] npm 9+ installed: `npm -v`
- [ ] Apache 2.4 installed: `apache2 -v`
- [ ] Oracle XE 21c installed and running
- [ ] Python 3.8+ installed: `python3 --version`
- [ ] Database migration scripts applied
- [ ] SSL certificates installed in `/etc/ssl/`
- [ ] Backup script tested: `./backup.sh`

### Application Configuration

- [ ] Backend: Configure `application.properties`
- [ ] Frontend: Configure API endpoints in `.env`
- [ ] Database: Oracle credentials set correctly
- [ ] Services: All Python requirements installed
- [ ] Apache: VirtualHost configured
- [ ] SSL: Certificates and keys in place

### Backup Preparation

- [ ] Run setup.sh: `sudo bash setup.sh`
- [ ] Create backup directories: `/backup`, `/var/log/teeth-management`
- [ ] Test backup script: `./backup.sh`
- [ ] Verify backup output: `/backup/files/`, `/backup/database/`
- [ ] Check versions file: `/backup/metadata/versions_*.txt`

---

## 🔍 Health Checks

### API Endpoints Health

```bash
# Backend API
curl -s http://localhost:8080/api/health | jq .

# Chatbot Service
curl -s http://localhost:8000/health | jq .

# Notifications
curl -s http://localhost:5000/health | jq .

# Web Application
curl -s http://localhost/ | head -20
```

### Service Status

```bash
# Check all critical services
for service in apache2 tomcat oracle-xe-21c; do
    echo "=== $service ==="
    systemctl status $service | head -3
done
```

### Database Connectivity

```bash
# Test Oracle connection
sqlplus sys/password@XE as sysdba
SQL> SELECT COUNT(*) FROM dba_tables;
SQL> EXIT;
```

---

## 🔐 Security Checklist

- [ ] Oracle SYS password set and documented securely
- [ ] Database users have minimum required privileges
- [ ] SSL/TLS certificates installed and valid
- [ ] Apache security headers configured
- [ ] Firewall rules allow only necessary ports
- [ ] SSH keys configured (no password-based root login)
- [ ] Backup directory permissions set correctly
- [ ] Database password hashes verified (bcrypt)
- [ ] API authentication implemented
- [ ] Logging enabled for audit trail

---

## 📊 Performance Tuning

### Java/Tomcat

```bash
# Set JVM memory (in /opt/tomcat/bin/catalina.sh)
export CATALINA_OPTS="-Xms2G -Xmx4G -XX:+UseG1GC"
```

### Oracle

```sql
-- Check database parameters
SHOW PARAMETERS db_cache_size;
SHOW PARAMETERS processes;
SHOW PARAMETERS open_cursors;

-- Increase if needed
ALTER SYSTEM SET db_cache_size=2G;
ALTER SYSTEM SET processes=500;
ALTER SYSTEM SET open_cursors=1000;
```

### Apache

```apache
# /etc/apache2/mods-available/mpm_prefork.conf
<IfModule mpm_prefork_module>
    StartServers            10
    MinSpareServers         5
    MaxSpareServers         15
    MaxRequestWorkers       256
    MaxConnectionsPerChild   0
</IfModule>
```

---

## 📞 Support & Documentation

- **Backup/Restore Guide**: `backup/BACKUP_RESTORE_GUIDE.md`
- **Database Details**: `backup/DATABASE_BACKUP_DETAILS.md`
- **Quick Reference**: `backup/QUICK_REFERENCE.txt`
- **Migration Guide**: `Docs/Database/MIGRATION_README.md`
- **Oracle Documentation**: https://docs.oracle.com/en/database/oracle/oracle-database/21/

---

**Last Updated:** March 29, 2026  
**System:** Teeth Management System v2.0  
**Maintained By:** Development & Operations Teams
