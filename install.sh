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
AI_DIR="$SCRIPT_DIR/Ai-chatbot"                             # Main project folder
REQ_FILE="$AI_DIR/requirements.txt"                         # Path to Python requirements file
ASTART="$AI_DIR/astart"                                     # Path to the 'astart' executable
VENV_DIR="$AI_DIR/venv"                                     # Virtual environment folder

# -----------------------------
# Function: Create Python virtual environment
# -----------------------------
create_venv() {
    # If venv already exists, skip creation
    if [[ -d "$VENV_DIR" && -f "$VENV_DIR/bin/activate" ]]; then
        ok "Virtual environment already exists at: $VENV_DIR"
        return 0
    fi

    # If python3 is missing, warn and exit gracefully
    if ! command -v python3 >/dev/null 2>&1; then
        warn "python3 not found; cannot create virtual environment now. It will be created after python3 is available."
        return 1
    fi

    # Try to create the virtual environment
    msg "Creating virtual environment at: $VENV_DIR"
    if python3 -m venv "$VENV_DIR"; then
        ok "Virtual environment created at: $VENV_DIR"
    else
        warn "Failed to create virtual environment at: $VENV_DIR"
        return 1
    fi
}

# Try to create venv right away, but don't stop if it fails (|| true)
create_venv || true

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

    # If a virtualenv exists in $VENV_DIR, activate it and install there
    if [[ -f "$VENV_DIR/bin/activate" ]]; then
        msg "Activating virtualenv at: $VENV_DIR"
        # shellcheck disable=SC1090
        source "$VENV_DIR/bin/activate"
        pip install --no-cache-dir -r "$REQ_FILE"
        ok "requirements installed into virtualenv: $VENV_DIR"
        return
    fi

    # If venv did not exist, try to create it and then install into it
    msg "No virtualenv detected at $VENV_DIR — attempting to create one for development"
    if create_venv; then
        if [[ -f "$VENV_DIR/bin/activate" ]]; then
            msg "Activating newly-created virtualenv at: $VENV_DIR"
            # shellcheck disable=SC1090
            source "$VENV_DIR/bin/activate"
            pip install --no-cache-dir -r "$REQ_FILE"
            ok "requirements installed into virtualenv: $VENV_DIR"
            return
        fi
    else
        warn "Virtualenv creation failed or skipped; falling back to system install."
    fi

    # Fallback: install system-wide (use sudo if not root)
    if [[ $EUID -eq 0 ]]; then
        python3 -m pip install --no-cache-dir -r "$REQ_FILE"
    else
        sudo python3 -m pip install --no-cache-dir -r "$REQ_FILE"
    fi
    ok "requirements installed system-wide (virtualenv not used)."
}

# -----------------------------
# Function: Install 'astart' launcher script
# -----------------------------
install_astart() {
    # Warn if source exists or not; we'll still create a launcher script
    if [[ ! -f "$ASTART" ]]; then
        warn "astart source not found at: $ASTART. Creating a default launcher instead."
    fi

    # Choose best destination directory
    DEST="/bin"
    if [[ -d "/usr/local/bin" ]]; then
        DEST="/usr/local/bin"
    fi

    msg "Installing astart to $DEST and making it executable..."

    # Launcher script content (creates a small CLI to start the chatbot)
    # Note: NC is used here as 'no color' to match common conventions.
    LAUNCHER_CONTENT='#!/usr/bin/env bash
# astart - launcher for Ai-chatbot
# Usage: astart -c   # run Streamlit web UI
#        astart -a   # run API only

# Colors
RED="\033[1;31m"
GREEN="\033[1;32m"
NC="\033[0m"

# Define paths
core_path="$HOME/Teeth-Management-System/Ai-chatbot"
Source_path="venv/bin/activate"

# To run the full AI chatbot with web interface
AI_chatbot_with_web(){
    cd "$core_path" || exit 1
    if [[ -f "$Source_path" ]]; then
        # shellcheck disable=SC1090
        source "$Source_path"
    fi
    streamlit run app.py
}

# To run only the API without the web interface
AI_chatbot_api_only(){
    cd "$core_path" || exit 1
    if [[ -f "$Source_path" ]]; then
        # shellcheck disable=SC1090
        source "$Source_path"
    fi
    python3 api.py
}

while getopts ":ca" option; do
    case $option in
        c)
            echo -e "${GREEN}Starting AI Chatbot with Web Interface...${NC}"
            AI_chatbot_with_web
            ;;
        a)
            echo -e "${GREEN}Starting AI Chatbot API Only...${NC}"
            AI_chatbot_api_only
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${NC}"
            ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    echo -e "${RED}No options were passed. Use -c for Chatbot with Web Interface or -a for API Only.${NC}"
fi'

    # Write launcher script, using sudo when not root
    if [[ $EUID -eq 0 ]]; then
        printf "%s\n" "$LAUNCHER_CONTENT" > "$DEST/astart"
        chmod +x "$DEST/astart"
    else
        sudo bash -c "printf '%s\n' \"$LAUNCHER_CONTENT\" > '$DEST/astart'"
        sudo chmod +x "$DEST/astart"
    fi

    ok "astart installed to $DEST/astart"
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

    # Detect Oracle by checking for 'oracle' user or /etc/oratab
    if ! id -u oracle >/dev/null 2>&1 && [[ ! -f /etc/oratab ]]; then
        ok "Oracle Database not detected. Skipping Oracle-specific prerequisites."
        return 0
    fi

    warn "Oracle Database presence detected. Checking system prerequisites..."

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

        # Make swap persistent across reboots
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
# Main installer function
# -----------------------------
main() {
    echo
    msg "Starting Ai-chatbot installer"

    # Run Oracle checks first
    ensure_oracle_prereqs

    # Create Python virtual environment
    create_venv

    # Ensure Python and pip are available
    ensure_python_pip

    # Install Python requirements
    install_requirements

    # Install Node.js system-wide (if apt system)
    install_node_system_wide

    # Copy 'astart' launcher
    install_astart

    echo
    ok "Installation complete."
}

# -----------------------------
# Run main function
# -----------------------------
main
