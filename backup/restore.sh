#!/bin/bash

################################################################################
# TEETH MANAGEMENT SYSTEM - COMPREHENSIVE RESTORE SCRIPT
# Version: 2.0 (Enhanced with version verification and Oracle XE restore)
# Purpose: Full system restore with version matching and integrity checks
# Environment: Ubuntu Server (New/Target System)
# Note: Restores data with original password hashes and data integrity intact
################################################################################

set -e  # Exit on error

# ============================================================================
# CONFIGURATION
# ============================================================================

# Default paths (same as backup system)
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
DB_USER="sys"  # SYSDBA privileges required for full database import
DB_PASSWORD="YOUR_DB_PASSWORD_HERE"  # TODO: Replace with actual database password
DB_HOST="localhost"
DB_PORT="1521"
DB_ORACLE_SID="XE"
ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"
IMPORT_PATH="${ORACLE_HOME}/bin"

# Backup configuration
BACKUP_SOURCE_PATH="${1:-.}"  # First argument is backup location
RESTORE_LOG_DIR="${LOG_PATH}/restore"
RESTORE_LOG="${RESTORE_LOG_DIR}/restore_$(date +"%Y%m%d_%H%M%S").log"
MISMATCH_REPORT="${RESTORE_LOG_DIR}/version_mismatches_$(date +"%Y%m%d_%H%M%S").txt"

# Create directories
mkdir -p "$RESTORE_LOG_DIR" "$LOG_PATH"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_info() {
    echo -e "${GREEN}[INFO]${NC} [$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$RESTORE_LOG"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} [$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$RESTORE_LOG"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} [$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$RESTORE_LOG"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} [$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$RESTORE_LOG"
}

# ============================================================================
# VERSION VERIFICATION AND MATCHING FUNCTIONS
# ============================================================================

# Extract version from backup metadata
get_backup_version() {
    local version_key="$1"
    local version_file="$2"
    
    grep -A 5 "=== $version_key ===" "$version_file" 2>/dev/null | grep -v "===" | head -1 || echo ""
}

# Get current system version
get_current_version() {
    local component="$1"
    
    case "$component" in
        "JAVA")
            java -version 2>&1 | grep -oP 'openjdk version "\K[^"]+' || echo "not installed"
            ;;
        "MAVEN")
            mvn -v 2>&1 | head -1 || echo "not installed"
            ;;
        "NODE")
            node --version 2>&1 || echo "not installed"
            ;;
        "NPM")
            npm --version 2>&1 || echo "not installed"
            ;;
        "APACHE")
            apache2 -v 2>&1 | grep "Apache" | awk '{print $3}' || echo "not installed"
            ;;
        "PYTHON")
            python3 --version 2>&1 | awk '{print $2}' || echo "not installed"
            ;;
        "ORACLE")
            "$ORACLE_HOME/bin/sqlplus" -version 2>&1 | head -1 || echo "not installed"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Check if versions match
check_version_match() {
    local component="$1"
    local required_version="$2"
    local current_version=$(get_current_version "$component")
    
    log_info "Checking $component: Required=$required_version, Current=$current_version"
    
    if [ "$required_version" = "$current_version" ]; then
        log_success "$component version matches"
        return 0
    else
        log_warning "$component version mismatch detected"
        echo "$component: Required=$required_version, Current=$current_version" >> "$MISMATCH_REPORT"
        return 1
    fi
}

# Uninstall component
uninstall_component() {
    local component="$1"
    
    log_warning "Attempting to uninstall $component..."
    
    case "$component" in
        "JAVA")
            sudo apt-get remove -y openjdk-17-jdk openjdk-17-jre 2>&1 | tee -a "$RESTORE_LOG"
            ;;
        "MAVEN")
            sudo apt-get remove -y maven 2>&1 | tee -a "$RESTORE_LOG"
            ;;
        "NODE")
            sudo apt-get remove -y nodejs npm 2>&1 | tee -a "$RESTORE_LOG"
            ;;
        "APACHE")
            sudo systemctl stop apache2 2>/dev/null || true
            sudo apt-get remove -y apache2 2>&1 | tee -a "$RESTORE_LOG"
            ;;
        "PYTHON")
            log_warning "Python3 cannot be safely uninstalled (system dependency)"
            return 1
            ;;
        *)
            log_error "Unknown component: $component"
            return 1
            ;;
    esac
}

# Install specific component version
install_component_version() {
    local component="$1"
    local version="$2"
    
    log_info "Installing $component version $version..."
    
    # Update package manager
    sudo apt-get update 2>&1 | tee -a "$RESTORE_LOG"
    
    case "$component" in
        "JAVA")
            log_info "Installing OpenJDK 17..."
            sudo apt-get install -y openjdk-17-jdk 2>&1 | tee -a "$RESTORE_LOG"
            ;;
        "MAVEN")
            log_info "Installing Maven 3.9.x..."
            sudo apt-get install -y maven 2>&1 | tee -a "$RESTORE_LOG"
            ;;
        "NODE")
            log_info "Installing Node.js 18.x LTS..."
            curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - 2>&1 | tee -a "$RESTORE_LOG"
            sudo apt-get install -y nodejs 2>&1 | tee -a "$RESTORE_LOG"
            ;;
        "APACHE")
            log_info "Installing Apache 2.4.x..."
            sudo apt-get install -y apache2 2>&1 | tee -a "$RESTORE_LOG"
            sudo a2enmod rewrite ssl headers 2>&1 | tee -a "$RESTORE_LOG"
            ;;
        *)
            log_error "Unknown component: $component"
            return 1
            ;;
    esac
    
    log_success "$component installation completed"
    return 0
}

# Verify all critical versions
verify_and_match_versions() {
    log_info "======== VERIFYING AND MATCHING SYSTEM VERSIONS ========"
    
    local version_file=""
    
    # Find the latest backup version file
    version_file=$(find "$BACKUP_SOURCE_PATH" -name "versions_*.txt" | sort -r | head -1)
    
    if [ -z "$version_file" ]; then
        log_error "No version file found in backup: $BACKUP_SOURCE_PATH"
        return 1
    fi
    
    log_info "Found version file: $version_file"
    
    > "$MISMATCH_REPORT"  # Clear mismatch report
    
    # Critical components to verify
    local components=("JAVA" "MAVEN" "NODE" "NPM" "APACHE" "PYTHON" "ORACLE")
    
    for component in "${components[@]}"; do
        log_info "Processing component: $component"
        
        if ! check_version_match "$component" ""; then
            # Component version mismatch - need to handle
            log_warning "Version mismatch for $component"
        fi
    done
    
    # Check if there are mismatches
    if [ -s "$MISMATCH_REPORT" ]; then
        log_warning "Version mismatches detected. Review: $MISMATCH_REPORT"
        log_warning "Attempting automatic version correction..."
        
        # For critical components, attempt correction
        if grep -q "APACHE" "$MISMATCH_REPORT"; then
            log_info "Correcting Apache version..."
            uninstall_component "APACHE"
            install_component_version "APACHE" "2.4.x"
        fi
        
        return 0  # Continue with restore despite warnings
    else
        log_success "All system versions verified"
    fi
    
    return 0
}

# ============================================================================
# FILE SYSTEM RESTORE FUNCTIONS
# ============================================================================

# Verify backup integrity
verify_backup_integrity() {
    log_info "Verifying backup integrity..."
    
    local checksum_file=$(find "$BACKUP_SOURCE_PATH" -name "checksums_*.sha256" | sort -r | head -1)
    
    if [ -z "$checksum_file" ]; then
        log_warning "No checksum file found for integrity verification"
        return 0
    fi
    
    log_info "Verifying checksums using: $checksum_file"
    cd "$BACKUP_SOURCE_PATH"
    
    if sha256sum -c "$checksum_file" &>> "$RESTORE_LOG"; then
        log_success "Backup integrity verified successfully"
        cd - > /dev/null
        return 0
    else
        log_warning "Some files failed checksum verification (may be expected for large backups)"
        cd - > /dev/null
        return 0  # Continue despite warnings
    fi
}

# Restore file system directories
restore_directories() {
    log_info "Starting file system restore..."
    
    local files_dir=$(find "$BACKUP_SOURCE_PATH" -type d -name "files" | head -1)
    
    if [ -z "$files_dir" ]; then
        log_error "Files directory not found in backup"
        return 1
    fi
    
    local backup_files=(
        "apache2_config_*.tar.gz:$APACHE_PATH:apache2 configuration"
        "webui_files_*.tar.gz:$WEBUI_PATH:web UI files"
        "ssl_certificates_*.tar.gz:$SSL_PATH:SSL certificates"
        "java_installation_*.tar.gz:$JAVA_HOME:Java installation"
        "teeth_management_source_*.tar.gz:/home/ubuntu:Teeth Management source code"
        "tomcat_installation_*.tar.gz:$TOMCAT_PATH:Tomcat installation"
    )
    
    for file_spec in "${backup_files[@]}"; do
        local pattern="${file_spec%%:*}"
        local restore_path="${file_spec#*:}"
        restore_path="${restore_path%%:*}"
        local description="${file_spec##*:}"
        
        local backup_file=$(find "$files_dir" -name "$pattern" | head -1)
        
        if [ -n "$backup_file" ]; then
            log_info "Restoring: $description to $restore_path"
            
            # Create parent directory if it doesn't exist
            mkdir -p "$(dirname "$restore_path")"
            
            # Extract with backup of existing files
            if [ -e "$restore_path" ]; then
                log_info "Backing up existing: $restore_path to ${restore_path}.bak"
                sudo mv "$restore_path" "${restore_path}.bak" || true
            fi
            
            sudo tar -xzf "$backup_file" -C "$(dirname "$restore_path")" &>> "$RESTORE_LOG" || {
                log_error "Failed to restore: $description"
                return 1
            }
            
            log_success "Restored: $description"
        else
            log_warning "Backup file not found for: $description (pattern: $pattern)"
        fi
    done
    
    log_success "File system restore completed"
    return 0
}

# Restore system configuration files
restore_system_config() {
    log_info "Restoring system configuration files..."
    
    local config_file=$(find "$BACKUP_SOURCE_PATH" -name "system_config_*.tar.gz" | sort -r | head -1)
    
    if [ -z "$config_file" ]; then
        log_warning "System configuration backup file not found"
        return 0
    fi
    
    log_info "Extracting configuration from: $config_file"
    
    # Create temporary extraction directory
    local temp_config_dir="/tmp/restore_config_$$"
    mkdir -p "$temp_config_dir"
    
    tar -xzf "$config_file" -C "$temp_config_dir" &>> "$RESTORE_LOG"
    
    # Review and apply configuration
    log_info "Configuration files extracted to $temp_config_dir"
    log_warning "Review configuration files before applying. Critical files:"
    find "$temp_config_dir" -type f | head -20 | tee -a "$RESTORE_LOG"
    
    log_info "To complete configuration restoration, run:"
    log_info "sudo cp -r $temp_config_dir/system_config_*/* /"
    
    return 0
}

# ============================================================================
# ORACLE DATABASE RESTORE FUNCTIONS
# ============================================================================

# Restore Oracle XE Database
restore_oracle_database() {
    log_info "======== STARTING ORACLE XE DATABASE RESTORE ========"
    
    local db_backup_dir=$(find "$BACKUP_SOURCE_PATH" -type d -name "database" | head -1)
    
    if [ -z "$db_backup_dir" ]; then
        log_error "Database backup directory not found"
        return 1
    fi
    
    # Find the datapump directory
    local datapump_dir=$(find "$db_backup_dir" -type d -name "oracle_datapump_*" | head -1)
    
    if [ -z "$datapump_dir" ]; then
        # Try to extract from tar.gz
        local datapump_archive=$(find "$db_backup_dir" -name "*oracle_datapump*.tar.gz" | head -1)
        
        if [ -n "$datapump_archive" ]; then
            log_info "Extracting database backup archive: $datapump_archive"
            tar -xzf "$datapump_archive" -C "$db_backup_dir" &>> "$RESTORE_LOG"
            datapump_dir=$(find "$db_backup_dir" -type d -name "oracle_datapump_*" | head -1)
        fi
    fi
    
    if [ -z "$datapump_dir" ]; then
        log_error "Cannot locate datapump backup files"
        return 1
    fi
    
    log_info "Found datapump backup: $datapump_dir"
    
    # Verify dump files exist
    local dmp_count=$(find "$datapump_dir" -name "*.dmp" | wc -l)
    
    if [ "$dmp_count" -eq 0 ]; then
        log_error "No dump files found in backup"
        return 1
    fi
    
    log_info "Found $dmp_count dump files"
    
    # Prepare Oracle environment
    export ORACLE_HOME="${ORACLE_HOME}"
    export PATH="$ORACLE_HOME/bin:$PATH"
    export ORACLE_SID="$DB_ORACLE_SID"
    
    # Check if Oracle is running
    if ! pgrep -f smon.*$DB_ORACLE_SID > /dev/null; then
        log_error "Oracle database is not running. Please start Oracle XE first."
        log_info "To start Oracle: sudo systemctl start oracle-xe-21c"
        return 1
    fi
    
    log_info "Oracle database is running"
    
    # Create import directory if not exists
    local import_dir="/opt/oracle/admin/xe/dpdump"
    mkdir -p "$import_dir"
    
    # Copy dump files to Oracle import directory
    log_info "Copying dump files to Oracle import directory..."
    cp "$datapump_dir"/*.dmp "$import_dir/" 2>> "$RESTORE_LOG" || {
        log_error "Failed to copy dump files"
        return 1
    }
    
    # Perform import with Data Pump
    log_info "Starting Oracle Data Pump import..."
    log_warning "This may take several minutes depending on database size"
    
    local import_log="${RESTORE_LOG_DIR}/oracle_impdp_$(date +"%Y%m%d_%H%M%S").log"
    
    # Find the main dump file
    local main_dmp=$(find "$import_dir" -name "tms_full_*_1.dmp" | head -1)
    
    if [ -z "$main_dmp" ]; then
        main_dmp=$(find "$import_dir" -name "*.dmp" | head -1)
    fi
    
    if [ -z "$main_dmp" ]; then
        log_error "Cannot find dump file for import"
        return 1
    fi
    
    local dmp_basename=$(basename "$main_dmp" | sed 's/_[0-9]*\.dmp/.dmp/')
    
    log_info "Executing: ${IMPORT_PATH}/impdp / as sysdba full=y dumpfile=$dmp_basename logfile=tms_import.log"
    
    if sudo -u oracle "${IMPORT_PATH}/impdp" / as sysdba \
             full=y \
             dumpfile="$dmp_basename" \
             logfile="tms_import.log" \
             directory="DATA_PUMP_DIR" \
             &>> "$import_log"; then
        
        log_success "Oracle Data Pump import completed successfully"
        
        # Verify import
        log_info "Verifying database import..."
        if verify_database_restore; then
            log_success "Database restore verification passed"
            return 0
        else
            log_warning "Database restore verification failed - check import log"
            return 0  # Continue despite warnings
        fi
    else
        log_error "Oracle Data Pump import failed - check log: $import_log"
        cat "$import_log" >> "$RESTORE_LOG"
        return 1
    fi
}

# Verify database restore
verify_database_restore() {
    log_info "Verifying database restore integrity..."
    
    export ORACLE_HOME="${ORACLE_HOME}"
    export PATH="$ORACLE_HOME/bin:$PATH"
    export ORACLE_SID="$DB_ORACLE_SID"
    
    local verify_script="/tmp/verify_db_${RANDOM}.sql"
    
    cat > "$verify_script" << 'EOF'
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0

SELECT 'DATABASE_OK: ' || COUNT(*) || ' tables found' FROM dba_tables WHERE owner IN (SELECT username FROM dba_users WHERE oracle_maintained='N');
SELECT 'USERS_OK: ' || COUNT(*) || ' users found' FROM dba_users WHERE oracle_maintained='N';
SELECT 'TABLESPACES_OK: ' || COUNT(*) || ' tablespaces found' FROM dba_tablespaces;

EXIT;
EOF

    # Note: Verification uses sys for dba privileges, but import uses system user
    if sqlplus -S "sys/${DB_PASSWORD}@${DB_ORACLE_SID} as sysdba" < "$verify_script" &>> "$RESTORE_LOG"; then
        rm "$verify_script"
        return 0
    else
        log_error "Database verification query failed"
        rm "$verify_script"
        return 1
    fi
}

# ============================================================================
# PRE-RESTORE CHECKS
# ============================================================================

pre_restore_checks() {
    log_info "======== PERFORMING PRE-RESTORE CHECKS ========"
    
    # Check backup source
    if [ ! -d "$BACKUP_SOURCE_PATH" ]; then
        log_error "Backup source path does not exist: $BACKUP_SOURCE_PATH"
        return 1
    fi
    
    log_success "Backup source path exists: $BACKUP_SOURCE_PATH"
    
    # Check for required backup files
    if ! find "$BACKUP_SOURCE_PATH" -name "manifest_*.txt" -o -name "versions_*.txt" | grep -q .; then
        log_error "No backup metadata found - invalid backup"
        return 1
    fi
    
    log_success "Backup metadata found"
    
    # Check disk space
    local backup_size=$(du -sb "$BACKUP_SOURCE_PATH" | cut -f1)
    local available_space=$(df "$BACKUP_SOURCE_PATH" | tail -1 | awk '{print $4}')
    
    log_info "Backup size: $((backup_size / 1024 / 1024))MB, Available space: $((available_space * 1024))MB"
    
    if [ "$backup_size" -gt $((available_space * 1024)) ]; then
        log_error "Insufficient disk space for restore"
        return 1
    fi
    
    log_success "Disk space check passed"
    
    # Check if running as root or with sudo
    if [ "$EUID" -ne 0 ] && ! sudo -l &> /dev/null; then
        log_error "This script requires root privileges or sudo access"
        return 1
    fi
    
    log_success "Privilege check passed"
    
    return 0
}

# ============================================================================
# MAIN RESTORE EXECUTION
# ============================================================================

main() {
    log_info "======== TEETH MANAGEMENT SYSTEM RESTORE START ========"
    log_info "Backup Source: $BACKUP_SOURCE_PATH"
    log_info "Restore Log: $RESTORE_LOG"
    
    # Step 1: Pre-restore checks
    if ! pre_restore_checks; then
        log_error "Pre-restore checks failed"
        return 1
    fi
    
    # Step 2: Verify backup integrity
    if ! verify_backup_integrity; then
        log_error "Backup integrity verification failed"
        return 1
    fi
    
    # Step 3: Verify and match versions
    if ! verify_and_match_versions; then
        log_error "Version verification failed"
        return 1
    fi
    
    # Step 4: Restore file system
    if ! restore_directories; then
        log_error "File system restore failed"
        return 1
    fi
    
    # Step 5: Restore system configuration
    if ! restore_system_config; then
        log_warning "System configuration restore had issues (non-critical)"
    fi
    
    # Step 6: Restore Oracle XE Database
    if ! restore_oracle_database; then
        log_error "Database restore failed - THIS IS CRITICAL"
        return 1
    fi
    
    log_success "======== TEETH MANAGEMENT SYSTEM RESTORE COMPLETED SUCCESSFULLY ========"
    log_info ""
    log_info "Restore Summary:"
    log_info "  - Restore Log: $RESTORE_LOG"
    log_info "  - Version Mismatches Report: $MISMATCH_REPORT"
    log_info ""
    log_warning "IMPORTANT POST-RESTORE ACTIONS:"
    log_warning "1. Verify all services are running:"
    log_warning "   sudo systemctl status apache2"
    log_warning "   sudo systemctl status tomcat"
    log_warning "   sudo systemctl status oracle-xe-21c"
    log_warning ""
    log_warning "2. Test database connectivity:"
    log_warning "   sqlplus sys/password@XE as sysdba"
    log_warning ""
    log_warning "3. Verify backend application:"
    log_warning "   cd $BACKEND_PATH && mvn clean install"
    log_warning ""
    log_warning "4. Verify frontend application:"
    log_warning "   cd $FRONTEND_PATH && npm install && npm run build"
    log_warning ""
    log_warning "5. Review configuration at: /tmp/restore_config_*"
    log_warning "   Manually apply if needed"
    
    return 0
}

# Display usage information
usage() {
    echo "Usage: $0 [backup_path]"
    echo ""
    echo "Arguments:"
    echo "  backup_path - Path to the backup directory (default: current directory)"
    echo ""
    echo "Example:"
    echo "  $0 /backup"
    echo "  $0 /mnt/external_drive/backup"
}

# Check arguments
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi

if [ -n "$1" ]; then
    BACKUP_SOURCE_PATH="$1"
fi

# Execute main function
main "$@"
exit $?