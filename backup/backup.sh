#!/bin/bash

################################################################################
# TEETH MANAGEMENT SYSTEM - COMPREHENSIVE BACKUP SCRIPT
# Version: 2.0 (Enhanced with version tracking and Oracle XE backup)
# Purpose: Full system backup including files, database schema, and version info
# Environment: Ubuntu Server (Production)
# Note: Password hashes and data integrity are preserved unchanged
################################################################################

set -e  # Exit on error

# ============================================================================
# CONFIGURATION
# ============================================================================

# Paths - System directories to backup
APACHE_PATH="/etc/apache2"
WEBUI_PATH="/var/www/html"
SSL_PATH="/etc/ssl"
JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
TOMCAT_PATH="/opt/tomcat"

# Source code - Single directory for GitHub sync
SOURCE_ROOT_PATH="$HOME/Teeth-Management-System"
BACKEND_PATH="${SOURCE_ROOT_PATH}/Backend"
FRONTEND_PATH="${SOURCE_ROOT_PATH}/Thoutha-Website"
AI_CHATBOT_PATH="${SOURCE_ROOT_PATH}/Ai-chatbot"
NOTIFICATIONS_PATH="${SOURCE_ROOT_PATH}/Notifications"
OTP_PATH="${SOURCE_ROOT_PATH}/OTP"
LOG_PATH="${SOURCE_ROOT_PATH}/logs"

# Database - Oracle XE Configuration
DB_USER="system"  # From application.properties
DB_PASSWORD="YOUR_DB_PASSWORD_HERE"  # TODO: Replace with actual database password
DB_HOST="localhost"
DB_PORT="1521"
DB_ORACLE_SID="XE"
ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"
EXPORT_PATH="${ORACLE_HOME}/bin"

# Backup configuration
BACKUP_ROOT_PATH="/backup"
BACKUP_METADATA_DIR="${BACKUP_ROOT_PATH}/metadata"
BACKUP_DB_DIR="${BACKUP_ROOT_PATH}/database"
BACKUP_FILES_DIR="${BACKUP_ROOT_PATH}/files"
BACKUP_LOG_DIR="${BACKUP_ROOT_PATH}/logs"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_ID="backup_${TIMESTAMP}"
VERSION_FILE="${BACKUP_METADATA_DIR}/versions_${TIMESTAMP}.txt"
BACKUP_MANIFEST="${BACKUP_METADATA_DIR}/manifest_${TIMESTAMP}.txt"
BACKUP_LOG="${BACKUP_LOG_DIR}/backup_${TIMESTAMP}.log"

# Create directories
mkdir -p "$BACKUP_ROOT_PATH" "$BACKUP_METADATA_DIR" "$BACKUP_DB_DIR" "$BACKUP_FILES_DIR" "$BACKUP_LOG_DIR"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo "[INFO] [$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_LOG"
}

log_error() {
    echo "[ERROR] [$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_LOG"
}

log_success() {
    echo "[SUCCESS] [$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$BACKUP_LOG"
}

# ============================================================================
# VERSION CAPTURE FUNCTIONS
# ============================================================================

# Capture system and service versions
capture_versions() {
    log_info "Capturing system and service versions..."
    
    {
        echo "=== TEETH MANAGEMENT SYSTEM BACKUP - VERSION MANIFEST ==="
        echo "Backup ID: $BACKUP_ID"
        echo "Backup Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"
        echo ""
        
        # Operating System
        echo "=== OPERATING SYSTEM ==="
        lsb_release -a 2>/dev/null || cat /etc/os-release
        uname -a
        echo ""
        
        # Java Version
        echo "=== JAVA ==="
        java -version 2>&1 || echo "Java not installed"
        echo "JAVA_HOME: $JAVA_HOME"
        echo ""
        
        # Maven Version
        echo "=== MAVEN ==="
        mvn -v 2>/dev/null || echo "Maven not installed"
        echo ""
        
        # Node.js & npm
        echo "=== NODE.JS & NPM ==="
        node --version 2>/dev/null || echo "Node.js not installed"
        npm --version 2>/dev/null || echo "npm not installed"
        echo ""
        
        # Apache/Httpd
        echo "=== APACHE2 ==="
        apache2 -v 2>/dev/null || apachectl -v 2>/dev/null || echo "Apache2 not installed"
        echo ""
        
        # Tomcat
        echo "=== TOMCAT ==="
        if [ -d "$TOMCAT_PATH" ]; then
            if [ -f "$TOMCAT_PATH/bin/version.sh" ]; then
                bash "$TOMCAT_PATH/bin/version.sh" 2>/dev/null || echo "Tomcat version unavailable"
            fi
        else
            echo "Tomcat not installed at $TOMCAT_PATH"
        fi
        echo ""
        
        # Python
        echo "=== PYTHON ==="
        python3 --version 2>/dev/null || echo "Python3 not installed"
        echo ""
        
        # Oracle Database
        echo "=== ORACLE DATABASE ==="
        if [ -n "$ORACLE_HOME" ] && [ -d "$ORACLE_HOME" ]; then
            "$ORACLE_HOME/bin/sqlplus" -version 2>/dev/null || echo "Oracle SQLPlus version unavailable"
        else
            echo "Oracle Database not installed"
        fi
        echo ""
        
        # OpenSSL
        echo "=== OPENSSL ==="
        openssl version
        echo ""
        
        # Installed Python packages
        echo "=== PYTHON PACKAGES ==="
        pip3 list 2>/dev/null || echo "pip3 not available"
        echo ""
        
        # Backend application version (if available)
        echo "=== BACKEND APPLICATION ==="
        if [ -f "$BACKEND_PATH/pom.xml" ]; then
            echo "Maven pom.xml found:"
            grep -E '<version>|<artifactId>' "$BACKEND_PATH/pom.xml" | head -5
        else
            echo "Backend path not found: $BACKEND_PATH"
        fi
        echo ""
        
        # Frontend application version (if available)
        echo "=== FRONTEND APPLICATION ==="
        if [ -f "$FRONTEND_PATH/package.json" ]; then
            echo "package.json found:"
            grep '"version"' "$FRONTEND_PATH/package.json"
        else
            echo "Frontend path not found: $FRONTEND_PATH"
        fi
        echo ""
        
        # Critical system libraries
        echo "=== CRITICAL LIBRARIES ==="
        dpkg -l | grep -E 'libssl|libcrypto|libpq' || echo "No matching libraries found"
        echo ""
        
    } > "$VERSION_FILE"
    
    log_success "Version information saved to $VERSION_FILE"
}

# ============================================================================
# DATABASE BACKUP FUNCTIONS
# ============================================================================

# Backup Oracle XE Database using Data Pump Export
backup_oracle_database() {
    log_info "Starting Oracle XE database backup..."
    
    local DB_BACKUP_DIR="${BACKUP_DB_DIR}/oracle_datapump_${TIMESTAMP}"
    mkdir -p "$DB_BACKUP_DIR"
    
    # Create a temporary script for Oracle export
    local EXPORT_SCRIPT="/tmp/export_db_${TIMESTAMP}.sql"
    
    cat > "$EXPORT_SCRIPT" << 'EOF'
SET ECHO OFF
SET FEEDBACK OFF

-- Enable full database export with all options
BEGIN
    DBMS_DATAPUMP.CREATE_JOB (
        job_mode => 'FULL',
        operation => 'EXPORT',
        job_name => 'FULL_DB_EXPORT',
        version => COMPATIBLE
    );
    DBMS_DATAPUMP.ADD_FILE (
        handle => job_handle,
        filename => 'backup_full_' || TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') || '.dmp',
        directory => 'DATA_PUMP_DIR',
        filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_DUMP_FILE
    );
    DBMS_DATAPUMP.ADD_FILE (
        handle => job_handle,
        filename => 'export_' || TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') || '.log',
        directory => 'DATA_PUMP_DIR',
        filetype => DBMS_DATAPUMP.KU$_FILE_TYPE_LOG_FILE
    );
    DBMS_DATAPUMP.START_JOB(job_handle);
END;
/
EOF

    log_info "Using Oracle Data Pump for database export..."
    
    # Use expdp command-line tool (preferred for full database backup)
    if [ -f "${EXPORT_PATH}/expdp" ]; then
        export ORACLE_HOME="${ORACLE_HOME}"
        export PATH="$ORACLE_HOME/bin:$PATH"
        export ORACLE_SID="$DB_ORACLE_SID"
        
        log_info "Executing: ${EXPORT_PATH}/expdp system/*** full=y dumpfile=tms_full_${TIMESTAMP}_%U.dmp logfile=tms_export_${TIMESTAMP}.log parallel=4"
        
        "${EXPORT_PATH}/expdp" "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID}" full=y \
              dumpfile="tms_full_${TIMESTAMP}_%U.dmp" \
              logfile="tms_export_${TIMESTAMP}.log" \
              directory="DATA_PUMP_DIR" \
              parallel=4 \
              exclude=statistics \
              flashback_time="TO_TIMESTAMP(SYSDATE,'DD-MM-YYYY HH24:MI:SS')" \
              &>> "$BACKUP_LOG"
        
        if [ $? -eq 0 ]; then
            log_success "Oracle Data Pump export completed successfully"
            
            # Move export files to backup directory
            mv /opt/oracle/admin/xe/dpdump/tms_full_${TIMESTAMP}*.dmp "$DB_BACKUP_DIR/" 2>/dev/null || true
            mv /opt/oracle/admin/xe/dpdump/tms_export_${TIMESTAMP}.log "$DB_BACKUP_DIR/" 2>/dev/null || true
        else
            log_error "Oracle Data Pump export failed"
            return 1
        fi
    else
        log_error "expdp not found at ${EXPORT_PATH}/expdp. Please ensure Oracle XE is properly installed and ORACLE_HOME is correct."
        return 1
    fi
    
    # Backup Oracle Control Files and Initialization Parameters
    log_info "Backing up Oracle control files and parameters..."
    
    local CONTROL_BACKUP_DIR="${DB_BACKUP_DIR}/control_files"
    mkdir -p "$CONTROL_BACKUP_DIR"
    
    # Create control file backup
    cat > "/tmp/control_file_backup_${TIMESTAMP}.sql" << 'EOF'
SET ECHO OFF
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SET LINESIZE 1000
ALTER DATABASE BACKUP CONTROLFILE TO TRACE AS '/opt/oracle/admin/xe/dpdump/control_file_trace.sql';
EOF

    log_info "Backing up Oracle parameter file (spfile)..."
    if [ -f "$ORACLE_HOME/dbs/spfileXE.ora" ]; then
        cp "$ORACLE_HOME/dbs/spfileXE.ora" "$CONTROL_BACKUP_DIR/"
    fi
    if [ -f "$ORACLE_HOME/dbs/initXE.ora" ]; then
        cp "$ORACLE_HOME/dbs/initXE.ora" "$CONTROL_BACKUP_DIR/"
    fi
    
    # Backup password file
    if [ -f "$ORACLE_HOME/dbs/orapwXE" ]; then
        cp "$ORACLE_HOME/dbs/orapwXE" "$CONTROL_BACKUP_DIR/"
    fi
    
    # Compress database backup
    log_info "Compressing database backup..."
    tar -czf "${DB_BACKUP_DIR}_backup_${TIMESTAMP}.tar.gz" \
        -C "$(dirname "$DB_BACKUP_DIR")" \
        "$(basename "$DB_BACKUP_DIR")" \
        &>> "$BACKUP_LOG"
    
    log_success "Oracle XE database backup completed"
    return 0
}

# Verify database backup integrity
verify_database_backup() {
    log_info "Verifying database backup integrity..."
    
    # Check if backup files exist and have content
    if [ -d "${BACKUP_DB_DIR}/oracle_datapump_${TIMESTAMP}" ]; then
        local dmp_count=$(find "${BACKUP_DB_DIR}/oracle_datapump_${TIMESTAMP}" -name "*.dmp" | wc -l)
        local log_count=$(find "${BACKUP_DB_DIR}/oracle_datapump_${TIMESTAMP}" -name "*.log" | wc -l)
        
        if [ "$dmp_count" -gt 0 ] && [ "$log_count" -gt 0 ]; then
            log_success "Database backup verified: $dmp_count dump files, $log_count log files"
            return 0
        fi
    fi
    
    log_error "Database backup verification failed"
    return 1
}

# ============================================================================
# FILE SYSTEM BACKUP FUNCTIONS
# ============================================================================

# Create manifest of backed up files
create_manifest() {
    log_info "Creating backup manifest..."
    
    {
        echo "=== BACKUP MANIFEST ==="
        echo "Backup ID: $BACKUP_ID"
        echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "=== DIRECTORIES BACKED UP ==="
        find "$BACKUP_FILES_DIR" -type f -ls | awk '{print $11, $7}' | sort
        echo ""
        echo "=== DATABASE BACKUP ==="
        find "$BACKUP_DB_DIR" -type f -ls | awk '{print $11, $7}' | sort
        echo ""
        echo "=== TOTAL BACKUP SIZE ==="
        du -sh "$BACKUP_ROOT_PATH"
    } > "$BACKUP_MANIFEST"
    
    log_success "Manifest created: $BACKUP_MANIFEST"
}

# Backup file system directories
backup_directories() {
    log_info "Starting file system backup..."
    
    local dirs_to_backup=(
        "$APACHE_PATH:apache2_config"
        "$WEBUI_PATH:webui_files"
        "$SSL_PATH:ssl_certificates"
        "$JAVA_HOME:java_installation"
        "/home/ubuntu/Teeth-Management-System:teeth_management_source"
        "$TOMCAT_PATH:tomcat_installation"
    )
    
    for dir_spec in "${dirs_to_backup[@]}"; do
        local dir_path="${dir_spec%:*}"
        local dir_name="${dir_spec#*:}"
        
        if [ -d "$dir_path" ]; then
            log_info "Backing up: $dir_path (as $dir_name)"
            
            tar -czf "${BACKUP_FILES_DIR}/${dir_name}_${TIMESTAMP}.tar.gz" \
                -C "$(dirname "$dir_path")" \
                "$(basename "$dir_path")" \
                --ignore-failed-read \
                2>> "$BACKUP_LOG" || log_error "Partial backup: $dir_path (some files may be in use)"
            
        else
            log_info "Directory not found (skipping): $dir_path"
        fi
    done
    
    log_success "File system backup completed"
}

# Backup additional configuration files
backup_config_files() {
    log_info "Backing up critical configuration files..."
    
    local config_files=(
        "/etc/hosts"
        "/etc/hostname"
        "/etc/network/interfaces"
        "/etc/apache2/sites-available"
        "/etc/apache2/sites-enabled"
        "/etc/apache2/conf-available"
        "/etc/apache2/conf-enabled"
        "/etc/apache2/mods-enabled"
        "/root/.bashrc"
        "/root/.bash_profile"
        "/etc/fstab"
        "/etc/sudoers"
        "/etc/cron.d"
        "/etc/crontab"
        "/root/.ssh"
    )
    
    local config_backup_dir="${BACKUP_FILES_DIR}/system_config_${TIMESTAMP}"
    mkdir -p "$config_backup_dir"
    
    for file_path in "${config_files[@]}"; do
        if [ -e "$file_path" ]; then
            log_info "Backing up: $file_path"
            cp -r "$file_path" "$config_backup_dir/" 2>/dev/null || true
        fi
    done
    
    tar -czf "${BACKUP_FILES_DIR}/system_config_${TIMESTAMP}.tar.gz" \
        -C "$(dirname "$config_backup_dir")" \
        "$(basename "$config_backup_dir")" \
        2>> "$BACKUP_LOG"
    
    rm -rf "$config_backup_dir"
    
    log_success "System configuration files backed up"
}

# ============================================================================
# ENCRYPTION AND INTEGRITY CHECK
# ============================================================================

# Generate checksums for integrity verification
generate_checksums() {
    log_info "Generating checksums for integrity verification..."
    
    local checksum_file="${BACKUP_METADATA_DIR}/checksums_${TIMESTAMP}.sha256"
    
    find "$BACKUP_ROOT_PATH" -type f ! -name "checksums_*" \
        -exec sha256sum {} \; > "$checksum_file"
    
    log_success "Checksums generated: $checksum_file"
}

# ============================================================================
# MAIN BACKUP EXECUTION
# ============================================================================

main() {
    log_info "======== TEETH MANAGEMENT SYSTEM BACKUP START ========"
    log_info "Backup ID: $BACKUP_ID"
    log_info "Backup Location: $BACKUP_ROOT_PATH"
    
    # Step 1: Capture versions
    if ! capture_versions; then
        log_error "Failed to capture versions"
        return 1
    fi
    
    # Step 2: Backup file system
    if ! backup_directories; then
        log_error "Failed to backup directories"
        return 1
    fi
    
    # Step 3: Backup configuration files
    if ! backup_config_files; then
        log_error "Failed to backup configuration files"
        return 1
    fi
    
    # Step 4: Backup Oracle XE Database
    if ! backup_oracle_database; then
        log_error "Failed to backup Oracle database - this is CRITICAL"
        return 1
    fi
    
    # Step 5: Verify database backup
    if ! verify_database_backup; then
        log_error "Database backup verification failed"
        return 1
    fi
    
    # Step 6: Create manifest
    if ! create_manifest; then
        log_error "Failed to create manifest"
        return 1
    fi
    
    # Step 7: Generate checksums
    if ! generate_checksums; then
        log_error "Failed to generate checksums"
        return 1
    fi
    
    log_success "======== TEETH MANAGEMENT SYSTEM BACKUP COMPLETED SUCCESSFULLY ========"
    log_info "Backup Summary:"
    log_info "  - Backup ID: $BACKUP_ID"
    log_info "  - Total Size: $(du -sh $BACKUP_ROOT_PATH | cut -f1)"
    log_info "  - Location: $BACKUP_ROOT_PATH"
    log_info "  - Log File: $BACKUP_LOG"
    log_info "  - Version File: $VERSION_FILE"
    log_info "  - Manifest: $BACKUP_MANIFEST"
    
    return 0
}

# Execute main function
main "$@"
exit $?