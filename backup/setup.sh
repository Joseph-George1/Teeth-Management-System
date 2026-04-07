#!/bin/bash

################################################################################
# SETUP HELPER - Prepare server for backup/restore operations
# Purpose: Install dependencies and validate configuration
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "\n${BLUE}============================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}============================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    print_error "This script must be run as root"
    echo "Run: sudo bash $0"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION=$VERSION_ID
else
    print_error "Cannot detect OS"
    exit 1
fi

print_header "Teeth Management System - Backup/Restore Setup"

echo "Operating System: $OS $VERSION"
echo "Hostname: $(hostname)"
echo "Current Date: $(date)"

# ============================================================================
# INSTALL DEPENDENCIES
# ============================================================================

print_header "Step 1: Installing System Dependencies"

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    print_warning "Updating package manager..."
    apt-get update -y
    
    # Install required tools
    print_warning "Installing required packages..."
    apt-get install -y \
        curl \
        wget \
        git \
        tar \
        gzip \
        bzip2 \
        unzip \
        rsync \
        openssh-client \
        openssh-server \
        openssl \
        ca-certificates \
        gnupg \
        lsb-release
    
    print_success "System dependencies installed"
else
    print_error "This script is optimized for Ubuntu/Debian"
    echo "Please manually install: curl wget git tar gzip bzip2 unzip rsync openssl"
fi

# ============================================================================
# INSTALL JAVA
# ============================================================================

print_header "Step 2: Installing Java 17 (For Backend)"

if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -1)
    print_success "Java already installed: $JAVA_VERSION"
else
    print_warning "Installing OpenJDK 17..."
    apt-get install -y openjdk-17-jdk
    print_success "Java 17 installed"
fi

# Verify
java -version

# ============================================================================
# INSTALL MAVEN
# ============================================================================

print_header "Step 3: Installing Maven (For Backend Build)"

if command -v mvn &> /dev/null; then
    MVN_VERSION=$(mvn -v 2>&1 | head -1)
    print_success "Maven already installed: $MVN_VERSION"
else
    print_warning "Installing Maven..."
    apt-get install -y maven
    print_success "Maven installed"
fi

# Verify
mvn -v | head -3

# ============================================================================
# INSTALL NODE.JS & NPM
# ============================================================================

print_header "Step 4: Installing Node.js 18 & npm (For Frontend)"

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_success "Node.js already installed: $NODE_VERSION"
    print_success "npm already installed: $NPM_VERSION"
else
    print_warning "Installing Node.js 18.x LTS..."
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    print_success "Node.js and npm installed"
fi

# Verify
node --version
npm --version

# ============================================================================
# INSTALL APACHE
# ============================================================================

print_header "Step 5: Installing Apache 2.4 (Web Server)"

if command -v apache2 &> /dev/null; then
    APACHE_VERSION=$(apache2 -v 2>&1 | grep "Apache" | awk '{print $3}')
    print_success "Apache already installed: $APACHE_VERSION"
else
    print_warning "Installing Apache 2.4..."
    apt-get install -y apache2 apache2-utils
    
    # Enable required modules
    print_warning "Enabling Apache modules..."
    a2enmod rewrite
    a2enmod ssl
    a2enmod headers
    a2enmod proxy
    a2enmod proxy_http
    a2enmod deflate
    
    # Enable and start service
    systemctl enable apache2
    systemctl start apache2
    
    print_success "Apache installed and configured"
fi

# Verify
apache2 -v | head -2

# ============================================================================
# INSTALL PYTHON & PIP
# ============================================================================

print_header "Step 6: Installing Python 3 (For Utilities)"

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    print_success "Python already installed: $PYTHON_VERSION"
else
    print_warning "Installing Python 3..."
    apt-get install -y python3 python3-pip python3-venv
    print_success "Python 3 installed"
fi

# Verify
python3 --version
pip3 --version

# Install useful Python packages
print_warning "Installing Python utilities..."
pip3 install --upgrade pip
pip3 install pyyaml requests

# ============================================================================
# PREPARE BACKUP DIRECTORIES
# ============================================================================

print_header "Step 7: Preparing Backup Directories"

BACKUP_PATHS=(
    "/backup"
    "/backup/metadata"
    "/backup/files"
    "/backup/database"
    "/backup/logs"
)

for path in "${BACKUP_PATHS[@]}"; do
    if [ ! -d "$path" ]; then
        print_warning "Creating: $path"
        mkdir -p "$path"
        chmod 700 "$path"
    else
        print_success "Exists: $path"
    fi
done

# ============================================================================
# CREATE BACKUP DIRECTORIES
# ============================================================================

print_header "Step 8: Creating Backup Infrastructure Directories"

# Create backup root directory structure
BACKUP_ROOT="/backup"
BACKUP_PATHS=(
    "$BACKUP_ROOT"
    "$BACKUP_ROOT/metadata"
    "$BACKUP_ROOT/database"
    "$BACKUP_ROOT/files"
    "$BACKUP_ROOT/logs"
)

for path in "${BACKUP_PATHS[@]}"; do
    if [ ! -d "$path" ]; then
        print_warning "Creating: $path"
        mkdir -p "$path"
        chmod 755 "$path"
    else
        print_success "Exists: $path"
    fi
done

# Ensure /home/ubuntu/Teeth-Management-System/logs exists for astart
if [ ! -d "$HOME/Teeth-Management-System/logs" ]; then
    print_warning "Creating: $HOME/Teeth-Management-System/logs"
    mkdir -p "$HOME/Teeth-Management-System/logs"
    chmod 755 "$HOME/Teeth-Management-System/logs"
else
    print_success "Exists: $HOME/Teeth-Management-System/logs"
fi

# ============================================================================
# CONFIGURE ORACLE DATABASE
# ============================================================================

print_header "Step 9: Oracle XE Database Configuration"

if [ -d "/opt/oracle" ]; then
    print_success "Oracle installation detected"
    
    # Verify Data Pump directory
    if [ -d "/opt/oracle/admin/xe/dpdump" ]; then
        print_success "Oracle Data Pump directory exists"
        chmod 777 /opt/oracle/admin/xe/dpdump
    else
        print_warning "Creating Oracle Data Pump directory..."
        mkdir -p /opt/oracle/admin/xe/dpdump
        chmod 777 /opt/oracle/admin/xe/dpdump
    fi
    
    # Check if Oracle is running
    if pgrep -f "oracle.*smon.*XE" > /dev/null; then
        print_success "Oracle XE is running"
    else
        print_warning "Oracle XE is not running"
        print_warning "To start: systemctl start oracle-xe-21c"
    fi
else
    print_warning "Oracle XE not detected"
    print_warning "Please install Oracle XE 21c before proceeding"
    echo ""
    echo "Installation steps:"
    echo "1. Download from: https://www.oracle.com/database/technologies/xe-downloads.html"
    echo "2. Follow official installation guide for your OS"
    echo "3. Ensure service oracle-xe-21c is created and enabled"
    echo ""
fi

# ============================================================================
# VERIFY BACKUP SCRIPTS
# ============================================================================

print_header "Step 10: Verifying Backup Scripts"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for script in "backup.sh" "restore.sh"; do
    if [ -f "$SCRIPT_DIR/$script" ]; then
        chmod +x "$SCRIPT_DIR/$script"
        print_success "Found and made executable: $script"
        
        # Validate syntax
        if bash -n "$SCRIPT_DIR/$script" 2>/dev/null; then
            print_success "Syntax valid: $script"
        else
            print_error "Syntax error in: $script"
        fi
    else
        print_error "Not found: $script"
    fi
done

# ============================================================================
# SYSTEM VERIFICATION
# ============================================================================

print_header "Step 11: System Verification Summary"

echo ""
echo -e "${BLUE}Java Environment:${NC}"
java -version 2>&1 | head -2

echo ""
echo -e "${BLUE}Maven Version:${NC}"
mvn -v 2>&1 | head -1

echo ""
echo -e "${BLUE}Node.js & npm:${NC}"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"

echo ""
echo -e "${BLUE}Apache Version:${NC}"
apache2 -v 2>&1 | head -1

echo ""
echo -e "${BLUE}Python Version:${NC}"
python3 --version

echo ""
echo -e "${BLUE}Disk Space:${NC}"
df -h /backup | tail -1

echo ""
echo -e "${BLUE}Backup Directory Structure:${NC}"
ls -lah /backup 2>/dev/null || echo "(Will be created on first backup)"

# ============================================================================
# FINAL INSTRUCTIONS
# ============================================================================

print_header "Setup Complete!"

echo -e "${GREEN}The system is now prepared for backup and restore operations.${NC}"
echo ""
echo "Next steps:"
echo ""

if [ "$1" = "backup-server" ]; then
    echo "1. On PRODUCTION SERVER (for backup):"
    echo "   export DB_PASSWORD='your_oracle_sys_password'"
    echo "   chmod +x $SCRIPT_DIR/backup.sh"
    echo "   $SCRIPT_DIR/backup.sh"
    echo ""
elif [ "$1" = "restore-server" ]; then
    echo "1. Ensure Oracle XE 21c is installed and running"
    echo "   sudo systemctl status oracle-xe-21c"
    echo ""
    echo "2. On NEW SERVER (for restore):"
    echo "   export DB_PASSWORD='your_oracle_sys_password'"
    echo "   chmod +x $SCRIPT_DIR/restore.sh"
    echo "   $SCRIPT_DIR/restore.sh /path/to/backup"
    echo ""
else
    echo "1. Prepare this system for:"
    echo "   - Backup: sudo bash $0 backup-server"
    echo "   - Restore: sudo bash $0 restore-server"
    echo ""
fi

echo "2. Review the documentation:"
echo "   - $SCRIPT_DIR/BACKUP_RESTORE_GUIDE.md"
echo "   - $SCRIPT_DIR/DATABASE_BACKUP_DETAILS.md"
echo "   - $SCRIPT_DIR/QUICK_REFERENCE.txt"
echo ""
echo "3. Set appropriate environment variables:"
echo "   export DB_PASSWORD='oracle_sys_password'"
echo "   export ORACLE_HOME='/opt/oracle/product/21c/dbhomeXE'"
echo ""
echo "For more information, see BACKUP_RESTORE_GUIDE.md"
echo ""

print_success "Setup complete! System is ready for backup/restore operations."
