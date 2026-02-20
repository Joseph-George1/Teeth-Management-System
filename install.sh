#!/usr/bin/env bash
# install.sh - Install python3, pip, requirements for Ai-chatbot and copy 'astart' to /bin
# Usage: sudo ./install.sh

# Exit immediately on error (-e), undefined variable (-u), or pipe failure (-o pipefail)
set -euo pipefail

# -----------------------------
# Configuration
# -----------------------------
VERSION="2.0.0"
INSTALL_LOG="/tmp/teeth-install-$(date +%Y%m%d-%H%M%S).log"
ROLLBACK_LOG="/tmp/teeth-rollback-$(date +%Y%m%d-%H%M%S).log"
MIN_DISK_SPACE_GB=10
MIN_PYTHON_VERSION="3.8"
MIN_NODE_VERSION="18"
ORACLE_SHA256="YOUR_ORACLE_CHECKSUM_HERE"  # Update with actual checksum

# Track installed components for rollback
declare -a INSTALLED_COMPONENTS=()
declare -a CREATED_FILES=()

# -----------------------------
# Define color variables for output
# -----------------------------
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
RESET="\033[0m"

# -----------------------------
# Helper functions for messages and logging
# -----------------------------
log_msg() {
    local level="$1"
    shift
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] [$level] $*" | tee -a "$INSTALL_LOG"
}

msg() { echo -e "${BLUE}==>${RESET} $1"; log_msg "INFO" "$1"; }   # Print normal info message
ok()  { echo -e "${GREEN}✔${RESET} $1"; log_msg "SUCCESS" "$1"; }    # Print success message
warn(){ echo -e "${YELLOW}⚠ $1${RESET}"; log_msg "WARNING" "$1"; }   # Print warning message
err() { echo -e "${RED}✖ $1${RESET}"; log_msg "ERROR" "$1"; rollback; exit 1; }  # Print error and exit

# Rollback function to undo changes on failure
rollback() {
    if [ ${#INSTALLED_COMPONENTS[@]} -eq 0 ] && [ ${#CREATED_FILES[@]} -eq 0 ]; then
        return
    fi
    
    warn "Installation failed. Rolling back changes..."
    
    # Remove created files
    for file in "${CREATED_FILES[@]}"; do
        if [ -f "$file" ] || [ -L "$file" ]; then
            rm -f "$file" 2>/dev/null && echo "Removed: $file" | tee -a "$ROLLBACK_LOG"
        fi
    done
    
    warn "Rollback complete. Check $ROLLBACK_LOG for details."
}

# Track created file
track_file() {
    CREATED_FILES+=("$1")
    echo "$1" >> "$ROLLBACK_LOG"
}

# Track installed component
track_component() {
    INSTALLED_COMPONENTS+=("$1")
    echo "Component: $1" >> "$ROLLBACK_LOG"
}

# -----------------------------
# Resolve script paths (works with sudo)
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Directory where the script is located
AI_DIR="$SCRIPT_DIR/Ai-chatbot"                             # Ai-chatbot folder (if present)
REQ_FILE="$SCRIPT_DIR/requirements.txt"                     # Path to Python requirements file
ASTART="$SCRIPT_DIR/astart"
oracle_url="https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm"
server_dir="/var/www/html"
WEBUI_PATH="$SCRIPT_DIR/Thoutha-Website"
BACKEND_PATH="$SCRIPT_DIR/Backend"

# Get the actual user (not root) when run with sudo
if [ -n "${SUDO_USER:-}" ]; then
    ACTUAL_USER="$SUDO_USER"
    ACTUAL_HOME=$(eval echo ~$SUDO_USER)
else
    ACTUAL_USER="$(whoami)"
    ACTUAL_HOME="$HOME"
fi

# -----------------------------
# Function: Check system requirements
# -----------------------------
check_system_requirements() {
    msg "Checking system requirements..."
    
    # Check disk space
    local available_space=$(df "$SCRIPT_DIR" | tail -1 | awk '{print int($4/1024/1024)}')
    if [ "$available_space" -lt "$MIN_DISK_SPACE_GB" ]; then
        err "Insufficient disk space. Need ${MIN_DISK_SPACE_GB}GB, found ${available_space}GB"
    fi
    ok "Disk space: ${available_space}GB available"
    
    # Check for required system commands
    local missing_cmds=()
    for cmd in curl wget git; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_cmds+=("$cmd")
        fi
    done
    
    if [ ${#missing_cmds[@]} -gt 0 ]; then
        err "Missing required commands: ${missing_cmds[*]}. Please install them first."
    fi
    ok "Required system commands found"
}

# -----------------------------
# Function: Compare versions
# Returns: 0 if $1 >= $2, 1 otherwise
# -----------------------------
version_gte() {
    printf '%s\n%s' "$2" "$1" | sort -V -C
}

# -----------------------------
# Function: Detect available package manager
# -----------------------------
detect_pkg_mgr() {
    if command -v apt-get >/dev/null 2>&1; then echo "apt-get"
    elif command -v dnf >/dev/null 2>&1; then echo "dnf"
    elif command -v yum >/dev/null 2>&1; then echo "yum"
    elif command -v pacman >/dev/null 2>&1; then echo "pacman"
    elif command -v zypper >/dev/null 2>&1; then echo "zypper"
    else echo ""; fi
}
# Save detected package manager name
PKG_MGR="$(detect_pkg_mgr)"
# If no supported package manager is found, warn user
if [[ -z "$PKG_MGR" ]]; then warn "No supported package manager found. You must install python3 and pip manually."; fi
# -----------------------------
# Function: Install Python packages based on detected manager
# -----------------------------
install_pkgs() {
    case "$PKG_MGR" in
        apt-get)
            msg "Updating apt and installing python3, python3-venv, python3-pip..."
            sudo apt-get update -y
            sudo apt-get install -y python3 python3-venv python3-pip
            ;;
        dnf)
            msg "Installing python3 and pip (dnf)..."
            sudo dnf install -y python3 python3-pip
            ;;
        yum)
            msg "Installing python3 and pip (yum)..."
            sudo yum install -y python3 python3-pip || sudo yum install -y python36 python36-pip
            ;;
        pacman)
            msg "Installing python and pip (pacman)..."
            sudo pacman -Sy --noconfirm python python-pip
            ;;
        zypper)
            msg "Installing python3 and pip (zypper)..."
            sudo zypper install -y python3 python3-pip
            ;;
        *)
            warn "Skipping automatic install of python/pip."
            ;;
    esac
}
# -----------------------------
# Function: Validate user input
# -----------------------------
validate_yes_no() {
    local input="$1"
    case "${input,,}" in  # Convert to lowercase
        y|yes) return 0 ;;
        n|no) return 1 ;;
        *) return 2 ;;
    esac
}

validate_number() {
    [[ "$1" =~ ^[0-9]+$ ]]
}

# -----------------------------
# Function: Ensure Python3 and pip are installed
# -----------------------------
ensure_python_pip() {
    # Check for python3
    if ! command -v python3 >/dev/null 2>&1; then
        if [[ -n "$PKG_MGR" ]]; then
            install_pkgs
        else
            err "python3 not found and no package manager detected."
        fi
    else
        local py_version=$(python3 --version 2>&1 | awk '{print $2}')
        ok "python3 found: $py_version"
        
        # Check minimum version
        if ! version_gte "$py_version" "$MIN_PYTHON_VERSION"; then
            err "Python $py_version found, but $MIN_PYTHON_VERSION or higher is required"
        fi
    fi

    # Check for pip
    if ! python3 -m pip --version >/dev/null 2>&1; then
        warn "pip for python3 not found. Attempting to bootstrap..."
        if python3 -m ensurepip --upgrade >/dev/null 2>&1; then
            ok "pip installed via ensurepip."
        elif [[ -n "$PKG_MGR" ]]; then
            install_pkgs
        else
            err "Unable to install pip. Install python3-pip manually."
        fi
    else
        ok "pip: $(python3 -m pip --version 2>&1)"
    fi
}
# -----------------------------
# Function: Install Python dependencies
# -----------------------------
install_requirements() {
    # Check if requirements.txt exists
    if [[ ! -f "$REQ_FILE" ]]; then
        warn "requirements.txt not found at $REQ_FILE. Skipping pip install."
        return
    fi

    msg "Installing Python requirements from $REQ_FILE ..."
    
    # Option to use virtual environment
    local use_venv=false
    echo -n "Install in virtual environment (recommended)? (y/n) [y]: "
    read -r -t 15 venv_choice || venv_choice="y"
    
    if validate_yes_no "${venv_choice:-y}"; then
        use_venv=true
        local venv_path="$SCRIPT_DIR/venv"
        
        if [ ! -d "$venv_path" ]; then
            msg "Creating virtual environment at $venv_path..."
            python3 -m venv "$venv_path"
            track_file "$venv_path"
        fi
        
        msg "Installing requirements in virtual environment..."
        source "$venv_path/bin/activate"
        python3 -m pip install --upgrade pip
        python3 -m pip install --no-cache-dir -r "$REQ_FILE"
        deactivate
        ok "Requirements installed in virtual environment at $venv_path"
        msg "To use: source $venv_path/bin/activate"
        track_component "python-venv"
        return
    fi

    # Try system-wide install first. If pip fails with a message
    # suggesting `--break-system-packages`, retry with that flag.
    set +e
    if [[ $EUID -eq 0 ]]; then
        output=$(python3 -m pip install --no-cache-dir -r "$REQ_FILE" 2>&1)
        rc=$?
    else
        output=$(sudo python3 -m pip install --no-cache-dir -r "$REQ_FILE" 2>&1)
        rc=$?
    fi
    set -e

    if [[ $rc -eq 0 ]]; then
        ok "Requirements installed system-wide."
        track_component "python-packages"
        return
    fi

    # If pip suggests using --break-system-packages, retry with that option
    if echo "$output" | grep -qi "break-system-packages"; then
        warn "pip reported system package protection; retrying with --break-system-packages..."
        set +e
        if [[ $EUID -eq 0 ]]; then
            output2=$(python3 -m pip install --break-system-packages --no-cache-dir -r "$REQ_FILE" 2>&1)
            rc2=$?
        else
            output2=$(sudo python3 -m pip install --break-system-packages --no-cache-dir -r "$REQ_FILE" 2>&1)
            rc2=$?
        fi
        set -e

        if [[ $rc2 -eq 0 ]]; then
            ok "requirements installed with --break-system-packages."
            return
        else
            warn "Retry with --break-system-packages also failed."
            err "Failed to install requirements. pip output:\n$output2"
        fi
    fi

    # Generic failure: surface pip output for debugging
    err "Failed to install requirements. pip output:\n$output"
}
# -----------------------------
# Function: Install Maven (required for backend)
# -----------------------------
install_maven() {
    if command -v mvn >/dev/null 2>&1; then
        ok "Maven already installed: $(mvn -v | head -1)"
        return 0
    fi
    
    msg "Maven not found. Installing..."
    case "$PKG_MGR" in
        apt-get)
            sudo apt-get install -y maven
            ;;
        dnf|yum)
            sudo "$PKG_MGR" install -y maven
            ;;
        pacman)
            sudo pacman -S --noconfirm maven
            ;;
        zypper)
            sudo zypper install -y maven
            ;;
        *)
            warn "Cannot auto-install Maven. Please install manually."
            return 1
            ;;
    esac
    
    if command -v mvn >/dev/null 2>&1; then
        ok "Maven installed successfully"
        track_component "maven"
    else
        err "Maven installation failed"
    fi
}

# -----------------------------
# Function: Install Java (required for backend)
# -----------------------------
install_java() {
    if command -v java >/dev/null 2>&1; then
        ok "Java already installed: $(java -version 2>&1 | head -1)"
        return 0
    fi
    
    msg "Java not found. Installing OpenJDK 17..."
    case "$PKG_MGR" in
        apt-get)
            sudo apt-get install -y openjdk-17-jdk
            ;;
        dnf|yum)
            sudo "$PKG_MGR" install -y java-17-openjdk-devel
            ;;
        pacman)
            sudo pacman -S --noconfirm jdk17-openjdk
            ;;
        zypper)
            sudo zypper install -y java-17-openjdk-devel
            ;;
        *)
            warn "Cannot auto-install Java. Please install manually."
            return 1
            ;;
    esac
    
    if command -v java >/dev/null 2>&1; then
        ok "Java installed successfully"
        track_component "java"
    else
        err "Java installation failed"
    fi
}

# -----------------------------
# Function: Install 'astart' launcher script
# Behavior: copy existing `astart` script from the repository (prefer
# $SCRIPT_DIR/astart, `/bin/astart`,
# overwriting any existing file. Do not rewrite/regen the launcher.
# -----------------------------
install_astart() {
    # Prefer an `astart` sitting next to this installer, otherwise look in Ai-chatbot/
    SRC="$SCRIPT_DIR/astart"

    if [[ ! -f "$SRC" ]]; then
        warn "No 'astart' launcher found at '$SCRIPT_DIR/astart' Skipping install."
        return 0
    fi

    DEST="/bin/astart"
    msg "Creating symbolic link for astart at $DEST (will overwrite if exists)..."

    if [[ $EUID -eq 0 ]]; then
        ln -sf "$SRC" "$DEST" 2>/dev/null
    else
        sudo ln -sf "$SRC" "$DEST" 2>/dev/null
    fi

    # Verify the symlink was created successfully
    if [[ -L "$DEST" ]] && command -v astart >/dev/null 2>&1; then
        ok "astart symlinked to $DEST and verified"
        msg "You can run it as: astart -h to see usage"
        track_file "$DEST"
        track_component "astart"
    else
        err "Failed to create or verify astart symlink at $DEST"
    fi
}
# -----------------------------
# Function: Install Node.js and npm packages
# -----------------------------
install_node_and_packages() {
    # Check if Node is already installed
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node -v | sed 's/v//')
        ok "Node.js already installed: v$node_version"
        
        # Check minimum version
        if ! version_gte "$node_version" "$MIN_NODE_VERSION"; then
            warn "Node.js $node_version found, but $MIN_NODE_VERSION or higher is recommended"
            echo -n "Upgrade Node.js? (y/n) [n]: "
            read -r -t 15 upgrade_choice || upgrade_choice="n"
            if ! validate_yes_no "${upgrade_choice:-n}"; then
                return 0
            fi
        else
            # Node is installed and version is good, install npm packages
            install_npm_packages
            return 0
        fi
    fi
    
    # Skip for non-apt systems
    if [[ "$PKG_MGR" != "apt-get" ]]; then
        warn "System-wide Node install currently supports apt-based systems only. Skipping."
        return 0
    fi

    msg "Installing Node.js system-wide via NodeSource..."

    # Handle dpkg conflicts (common.gypi issue)
    CONFLICT_FILE="/usr/include/node/common.gypi"
    OWNER_INFO=$(dpkg -S "$CONFLICT_FILE" 2>/dev/null || true)
    if [[ -n "$OWNER_INFO" ]]; then
        warn "Detected package(s) owning $CONFLICT_FILE: $OWNER_INFO"
        msg "Removing likely-conflicting packages: libnode-dev libnode72 nodejs npm (if present)"
        sudo apt remove --purge -y libnode-dev libnode72 nodejs npm || true
        sudo apt autoremove -y || true
        sudo apt-get clean || true
        sudo rm -f /var/cache/apt/archives/nodejs_*.deb || true
        sudo apt-get -f install -y || true
    else
        msg "No obvious dpkg conflict found for $CONFLICT_FILE. Proceeding with NodeSource install."
    fi

    # Ask user which Node version to install (default 20)
    echo -n "Which Node major version do you want to install? (20/18) [20]: "
    read -r -t 15 NODE_VER || NODE_VER="20"
    NODE_VER=${NODE_VER:-20}
    
    # Validate input
    if ! validate_number "$NODE_VER" || [[ "$NODE_VER" != "18" && "$NODE_VER" != "20" ]]; then
        warn "Invalid input '$NODE_VER'; defaulting to 20"
        NODE_VER=20
    fi

    # Configure NodeSource repo
    if [[ "$NODE_VER" == "20" ]]; then
        msg "Configuring NodeSource repository for Node 20..."
        curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    else
        msg "Configuring NodeSource repository for Node 18..."
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    fi

    # Install Node.js
    msg "Installing nodejs package via apt..."
    sudo apt-get install -y nodejs

    # Verify installation
    if command -v node >/dev/null 2>&1; then
        ok "Node installed: $(node -v)"
        ok "npm installed: $(npm -v)"
        track_component "nodejs"
        
        # Install npm packages for web UI
        install_npm_packages
    else
        err "Node installation failed. Check apt output above."
    fi
}

# -----------------------------
# Function: Install npm packages for web UI
# -----------------------------
install_npm_packages() {
    if [ ! -d "$WEBUI_PATH" ]; then
        warn "Web UI directory not found at $WEBUI_PATH. Skipping npm install."
        return 0
    fi
    
    if [ ! -f "$WEBUI_PATH/package.json" ]; then
        warn "package.json not found in $WEBUI_PATH. Skipping npm install."
        return 0
    fi
    
    msg "Installing npm packages for Web UI..."
    cd "$WEBUI_PATH" || return 1
    
    npm install || {
        err "Failed to install npm packages"
    }
    
    ok "npm packages installed successfully"
    track_component "npm-packages"
    cd "$SCRIPT_DIR"
}
# -----------------------------
# Function: Check and fix prerequisites for Oracle Database
# -----------------------------
ensure_oracle_prereqs() {
    msg "Checking for Oracle Database presence..."

    # Detect Oracle NOT installed
    if ! id -u oracle >/dev/null 2>&1 && [[ ! -f /etc/oratab ]]; then
        warn "Oracle Database not detected on this system."
        msg "Proceeding with Oracle Database installation..."
        sudo wget -q -O /tmp/oracle-database.rpm "$oracle_url"

        # ---------------------
        # Progress bar function
        # ---------------------
        show_progress() {
            local pid=$1
            local spin='|/-\'
            local i=0

            printf "Progress: ["

            while kill -0 "$pid" 2>/dev/null; do
                printf "\b${spin:i++%4:1}"
                sleep 0.15
            done

            printf "\b✓]\n"
        }

        case "$PKG_MGR" in
            apt-get)
                msg "Updating package lists..."
                sudo apt-get update -y >/dev/null 2>&1 &
                show_progress $!

                msg "Installing 'alien' (required for converting RPM to DEB)..."
                sudo apt-get install -y alien >/dev/null 2>&1 &
                show_progress $!

                msg "Converting Oracle RPM to DEB and installing it (this may take several minutes)..."
                sudo alien -i /tmp/oracle-database.rpm >/dev/null 2>&1 &
                show_progress $!

                ;;
            dnf|yum)
                sudo "$PKG_MGR" install -y /tmp/oracle-database.rpm
                ;;
            zypper)
                sudo zypper install -y /tmp/oracle-database.rpm
                ;;
            pacman)
                msg "Pacman does not support RPM installation. Skipping."
                ;;
            *)
                warn "Unknown package manager. Cannot install Oracle automatically."
                ;;
        esac

        ok "Oracle installation step completed."
        return 0
    fi

    ok "Oracle installation detected. Continuing with prerequisite checks..."

    # 1. Check and create Swap space (min 4GB)
    local SWAP_KB
    SWAP_KB=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    local MIN_SWAP_KB=4194304 # 4GB

    if [[ "$SWAP_KB" -lt "$MIN_SWAP_KB" ]]; then
        warn "Insufficient swap space (Found ${SWAP_KB} kB). Creating 4GB swap file at /swapfile..."
        sudo fallocate -l 4G /swapfile
        sudo chmod 600 /swapfile
        sudo mkswap /swapfile
        sudo swapon /swapfile

        if ! grep -q '/swapfile' /etc/fstab; then
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
            ok "Swap file created, enabled, and added to /etc/fstab."
        else
            ok "Swap file created and enabled."
        fi
    else
        ok "Sufficient swap space found (${SWAP_KB} kB)."
    fi

    # 2. Install required packages
    msg "Installing Oracle-specific dependencies (libaio, bc, sysstat, unixodbc)..."
    case "$PKG_MGR" in
        apt-get)
            sudo apt-get install -y libaio1 bc sysstat unixodbc build-essential
            ;;
        dnf|yum)
            sudo "$PKG_MGR" install -y libaio bc sysstat unixODBC
            ;;
        pacman)
            sudo pacman -Sy --noconfirm libaio bc sysstat unixodbc
            ;;
        zypper)
            sudo zypper install -y libaio1 bc sysstat unixODBC
            ;;
        *)
            warn "Cannot auto-install Oracle dependencies for unknown package manager."
            ;;
    esac

    # 3. Set security limits for 'oracle' user
    if ! grep -q "oracle hard nproc" /etc/security/limits.conf; then
        msg "Setting Oracle security limits in /etc/security/limits.conf"
        printf "%s\n" \
            "oracle soft nofile 1024" \
            "oracle hard nofile 65536" \
            "oracle soft nproc 2047" \
            "oracle hard nproc 16384" \
            "oracle soft stack 10240" \
            "oracle hard stack 32768" | sudo tee -a /etc/security/limits.conf > /dev/null
    else
        ok "Oracle security limits seem to be set."
    fi

    # 4. Set kernel parameters
    if ! grep -q "fs.file-max" /etc/sysctl.conf; then
        msg "Setting Oracle kernel parameters in /etc/sysctl.conf"
        printf "%s\n" \
            "fs.file-max = 6815744" \
            "kernel.shmmax = 68719476736" \
            "kernel.shmall = 4294967296" \
            "kernel.sem = 250 32000 100 128" \
            "net.ipv4.ip_local_port_range = 9000 65500" \
            "net.core.rmem_default = 262144" \
            "net.core.wmem_default = 262144" \
            "net.core.rmem_max = 4194304" \
            "net.core.wmem_max = 1048576" | sudo tee -a /etc/sysctl.conf > /dev/null

        msg "Applying kernel parameters..."
        sudo sysctl -p
    else
        ok "Oracle kernel parameters seem to be set."
    fi

    ok "Oracle prerequisites check and fix complete."
} 
# -----------------------------
# Function: Setup .env configuration file
# -----------------------------
setup_env_file() {
    local env_file="$SCRIPT_DIR/.env"
    local env_example="$SCRIPT_DIR/.env.example"
    
    if [ -f "$env_file" ]; then
        ok ".env file already exists at $env_file"
        return 0
    fi
    
    msg "Creating .env configuration file..."
    
    if [ -f "$env_example" ]; then
        cp "$env_example" "$env_file"
        ok ".env file created from .env.example"
    else
        # Create basic .env file
        cat > "$env_file" << 'EOF'
# Teeth Management System Configuration

# Database Configuration
DB_URL=jdbc:oracle:thin:@localhost:1521/orclpdb
DB_USERNAME=hr
DB_PASSWORD=hr

# Port Configuration
WEB_UI_PORT=5173
BACKEND_PORT=8080
API_PORT=5010
LOGIN_API_PORT=5000
EOF
        ok ".env file created with default values"
    fi
    
    warn "Please review and update $env_file with your actual configuration"
    track_file "$env_file"
}

#---------------------------------------------------------------------
#Function to fetch the latest code from the repository and update the 
#Production server 
#---------------------------------------------------------------------
update_production_server() {
    echo -e "${GREEN}Updating production server...${NC}"

    # Validate target directory (safety check)
    if [ ! -d "$server_dir" ] || [ -z "$server_dir" ] || [ "$server_dir" = "/" ]; then
        echo -e "${RED}ERROR: Invalid or dangerous server_dir: '$server_dir'${NC}"
        exit 1
    fi

    # Validate web UI path
    if [ ! -d "$WEBUI_PATH" ]; then
        err "Web UI directory not found at $WEBUI_PATH"
    fi
    
    # Move to the web UI directory
    cd "$WEBUI_PATH" || { 
        err "Failed to change directory to $WEBUI_PATH"
    }

    # Pull latest changes
    git pull origin main || { 
        echo -e "${RED}Git pull failed. Please check your network or repo status.${NC}"
        exit 1
    }
    echo -e "${GREEN}Production server updated from Git successfully.${NC}"

    # Build project
    npm run build || { 
        echo -e "${RED}Build failed. Check the build logs for details.${NC}"
        exit 1
    }

    # Remove old production files except .htaccess
    echo -e "${GREEN}Cleaning old production files...${NC}"
    sudo find "$server_dir" -mindepth 1 ! -name ".htaccess" -exec rm -rf {} + || { 
        echo -e "${RED}Failed to remove old files from $server_dir${NC}"
        exit 1
    }
    echo -e "${GREEN}Old files removed from $server_dir successfully.${NC}"

    # Copy new build
    sudo cp -r dist/* "$server_dir"/ || { 
        echo -e "${RED}Failed to copy files to $server_dir${NC}"
        exit 1
    }
    echo -e "${GREEN}Files copied to $server_dir successfully.${NC}"

    echo -e "${GREEN}Deployment completed successfully!${NC}"
}



# -----------------------------
# Function: Display interactive menu
# -----------------------------
show_menu() {
    echo
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${CYAN}║${RESET}    Teeth Management System - Installation Menu v$VERSION  ${CYAN}║${RESET}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${GREEN}Select components to install:${RESET}"
    echo
    echo -e "  ${BLUE}1)${RESET} Full Installation (All components)"
    echo -e "  ${BLUE}2)${RESET} Python Dependencies Only"
    echo -e "  ${BLUE}3)${RESET} Node.js and Web UI Packages"
    echo -e "  ${BLUE}4)${RESET} Java and Maven (Backend)"
    echo -e "  ${BLUE}5)${RESET} Oracle Database Prerequisites"
    echo -e "  ${BLUE}6)${RESET} Install astart Launcher"
    echo -e "  ${BLUE}7)${RESET} Setup .env Configuration"
    echo -e "  ${BLUE}8)${RESET} Update Production Server"
    echo -e "  ${BLUE}9)${RESET} Custom Selection"
    echo -e "  ${BLUE}0)${RESET} Exit"
    echo
    echo -n "Enter your choice [1]: "
}

# -----------------------------
# Function: Display post-install instructions
# -----------------------------
show_post_install() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${GREEN}║${RESET}           Installation Complete!                          ${GREEN}║${RESET}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo
    echo -e "${CYAN}Next Steps:${RESET}"
    echo -e "  1. Review and update: ${YELLOW}$SCRIPT_DIR/.env${RESET}"
    echo -e "  2. Start all services: ${YELLOW}astart -w${RESET}"
    echo -e "  3. Check service status: ${YELLOW}astart -l${RESET}"
    echo -e "  4. View logs: ${YELLOW}astart -L <service_name>${RESET}"
    echo
    echo -e "${CYAN}Available Services:${RESET}"
    echo -e "  - Backend (Spring Boot): Port 8080"
    echo -e "  - Login API: Port 5000"
    echo -e "  - AI Chatbot API: Port 5010"
    echo -e "  - Web UI (Vite): Port 5173"
    echo
    echo -e "${CYAN}Documentation:${RESET}"
    echo -e "  - Installation log: ${YELLOW}$INSTALL_LOG${RESET}"
    echo -e "  - Rollback log: ${YELLOW}$ROLLBACK_LOG${RESET}"
    echo -e "  - Help: ${YELLOW}astart -h${RESET}"
    echo
    echo -e "${MAGENTA}For issues or questions, check the README.md file${RESET}"
    echo
}

# -----------------------------
# Main installer function
# -----------------------------
main() {
    echo
    msg "Starting installation protocol v$VERSION..."
    msg "Installation log: $INSTALL_LOG"
    echo
    
    # Check system requirements first
    check_system_requirements
    
    msg "Detected package manager: ${PKG_MGR:-None}"
    echo
    
    # Show interactive menu
    show_menu
    read -r -t 30 menu_choice || menu_choice="1"
    menu_choice=${menu_choice:-1}
    
    case "$menu_choice" in
        1)
            msg "Full installation selected"
            INSTALL_PYTHON=true
            INSTALL_NODE=true
            INSTALL_JAVA=true
            INSTALL_ORACLE=true
            INSTALL_ASTART=true
            SETUP_ENV=true
            ;;
        2)
            INSTALL_PYTHON=true
            ;;
        3)
            INSTALL_NODE=true
            ;;
        4)
            INSTALL_JAVA=true
            ;;
        5)
            INSTALL_ORACLE=true
            ;;
        6)
            INSTALL_ASTART=true
            ;;
        7)
            SETUP_ENV=true
            ;;
        8)
            update_production_server
            exit 0
            ;;
        9)
            msg "Custom selection - you will be prompted for each component"
            INSTALL_PYTHON=true
            INSTALL_NODE=true
            INSTALL_JAVA=true
            INSTALL_ORACLE=false
            INSTALL_ASTART=true
            SETUP_ENV=true
            ;;
        0)
            msg "Installation cancelled by user"
            exit 0
            ;;
        *)
            warn "Invalid choice, defaulting to full installation"
            INSTALL_PYTHON=true
            INSTALL_NODE=true
            INSTALL_JAVA=true
            INSTALL_ORACLE=true
            INSTALL_ASTART=true
            SETUP_ENV=true
            ;;
    esac
    
    echo
    # Ensure Python and pip are available
    if [ "${INSTALL_PYTHON:-false}" = true ]; then
        ensure_python_pip
        install_requirements
    fi

    
    # Install Java and Maven for backend
    if [ "${INSTALL_JAVA:-false}" = true ]; then
        install_java
        install_maven
    fi
    
    # Install Node.js and npm packages
    if [ "${INSTALL_NODE:-false}" = true ]; then
        install_node_and_packages
    fi
    
    # Setup .env file
    if [ "${SETUP_ENV:-false}" = true ]; then
        setup_env_file
    fi
    
    # Install astart launcher
    if [ "${INSTALL_ASTART:-false}" = true ]; then
        install_astart
    fi
    
    # Run Oracle checks
    if [ "${INSTALL_ORACLE:-false}" = true ]; then
        echo
        msg "Oracle Database installation is optional and requires 2GB+ download."
        echo -n "Install Oracle Database prerequisites? (y/n) [n]: "
        read -r -t 30 oracle_choice || oracle_choice="n"
        
        if validate_yes_no "${oracle_choice:-n}"; then
            ensure_oracle_prereqs
        else
            msg "Skipping Oracle Database installation."
        fi
    fi
    
    # Ask about production server update
    echo
    echo -n "Do you want to update the production server? (y/n) [n]: "
    read -r -t 30 update_choice || update_choice="n"
    
    if validate_yes_no "${update_choice:-n}"; then
        update_production_server
    else
        msg "Skipping production server update."
    fi
    
    echo
    ok "Installation completed successfully!"
    echo
    
    # Show post-install instructions
    show_post_install
}

# -----------------------------
# Run main function
# -----------------------------
main
