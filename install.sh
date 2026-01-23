#!/usr/bin/env bash
# install.sh - Install python3, pip, requirements for Ai-chatbot and copy 'astart' to /bin
# Usage: sudo ./install.sh

# Exit immediately on error (-e), undefined variable (-u), or pipe failure (-o pipefail)
set -euo pipefail

# -----------------------------
# Define color variables for output
# -----------------------------
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
RESET="\033[0m"

# -----------------------------
# Helper functions for messages
# -----------------------------
msg() { echo -e "${BLUE}==>${RESET} $1"; }   # Print normal info message
ok()  { echo -e "${GREEN}✔${RESET} $1"; }    # Print success message
warn(){ echo -e "${YELLOW}⚠ $1${RESET}"; }   # Print warning message
err() { echo -e "${RED}✖ $1${RESET}"; exit 1; }  # Print error and exit

# -----------------------------
# Resolve script paths
# -----------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # Directory where the script is located
AI_DIR="$SCRIPT_DIR/Ai-chatbot"                             # Ai-chatbot folder (if present)
REQ_FILE="$AI_DIR/requirements.txt"                         # Path to Python requirements file
# Primary `astart` location is now next to the installer (project root).
ASTART="$SCRIPT_DIR/astart"
oracle_url="https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-21c-1.0-1.ol8.x86_64.rpm"
server_dir="/var/www/html"
webui_path="$HOME/Teeth-Management-System/Thoutha-Website"
# Note: virtualenv creation/activation removed — installer will
# install requirements system-wide (with an optional retry using
# --break-system-packages if pip complains about system packages).

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
        ok "python3 found: $(python3 --version 2>&1)"
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
    # Check if Ai-chatbot directory exists
    if [[ ! -d "$AI_DIR" ]]; then
        err "Ai-chatbot directory not found at: $AI_DIR"
    fi

    # Check if requirements.txt exists
    if [[ ! -f "$REQ_FILE" ]]; then
        warn "requirements.txt not found at $REQ_FILE. Skipping pip install."
        return
    fi

    msg "Installing Python requirements from $REQ_FILE ..."

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
        ok "requirements installed system-wide."
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
    msg "Installing astart to $DEST (will overwrite if exists)..."

    if [[ $EUID -eq 0 ]]; then
        cp -f "$SRC" "$DEST"
        chmod +x "$DEST"
    else
        sudo cp -f "$SRC" "$DEST"
        sudo chmod +x "$DEST"
    fi

    ok "astart installed to $DEST"
    msg "You can run it as: astart (-c or -a)"
}

# -----------------------------
# Function: Install Node.js system-wide using NodeSource (apt-based systems only)
# -----------------------------
install_node_system_wide() {
    # Skip for non-apt systems
    if [[ "$PKG_MGR" != "apt-get" ]]; then
        warn "Option B (system-wide Node install) currently supports apt-based systems only. Skipping."
        return 0
    fi

    msg "Option B: Install Node.js system-wide via NodeSource (may remove conflicting dev packages)."

    # If Node is already installed, skip
    if command -v node >/dev/null 2>&1; then
        ok "Node is already installed: $(node -v)"
        return 0
    fi

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
    read -r -p "Which Node major version do you want to install? (20/18) [20]: " NODE_VER
    NODE_VER=${NODE_VER:-20}
    if [[ "$NODE_VER" != "18" && "$NODE_VER" != "20" ]]; then
        warn "Unrecognized choice; defaulting to 20"
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
    else
        err "Node installation failed. Check apt output above. You can try the non-invasive Option A (nvm) instead."
    fi
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

    # Move to the web UI directory
    cd "$webui_path" || { 
        echo -e "${RED}Failed to change directory to $webui_path${NC}"
        exit 1
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
# Main installer function
# -----------------------------
main() {
    echo
    msg "Starting installation protocol... "
    echo
    msg "Detected package manager: ${PKG_MGR:-None}"
    fi
    # Ensure Python and pip are available
    ensure_python_pip

    # Install Python requirements
    install_requirements

    # Install Node.js system-wide (if apt system)
    install_node_system_wide
    #install production server update prompt
    echo
    msg "Do you want to update the production server? (y/n) [default: n, auto-skip after 30s]"
    if ! read -t 30 -r update_choice; then
        update_choice="n"
        msg "No response received within 30 seconds; skipping production server update."
    fi
    if [[ "$update_choice" = "y" ]]; then
        update_production_server
    else
        msg "Skipping production server update."
    fi

    # Copy 'astart' launcher
    install_astart

    # Run Oracle checks first
    ensure_oracle_prereqs

    echo
    ok "Installation complete."
}

# -----------------------------
# Run main function
# -----------------------------
main
