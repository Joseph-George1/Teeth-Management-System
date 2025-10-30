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

    # Install requirements (use sudo if not root)
    if [[ $EUID -eq 0 ]]; then
        python3 -m pip install --no-cache-dir -r "$REQ_FILE"
    else
        sudo python3 -m pip install --no-cache-dir -r "$REQ_FILE"
    fi
    ok "requirements installed."
}

# -----------------------------
# Function: Copy 'astart' to /usr/local/bin or /bin
# -----------------------------
install_astart() {
    # Ensure file exists
    if [[ ! -f "$ASTART" ]]; then
        err "astart not found at: $ASTART"
    fi

    # Choose best destination directory
    DEST="/bin"
    if [[ -d "/usr/local/bin" ]]; then
        DEST="/usr/local/bin"
    fi

    msg "Copying astart to $DEST and making it executable..."

    # Copy with or without sudo based on privileges
    if [[ $EUID -eq 0 ]]; then
        cp "$ASTART" "$DEST/astart"
        chmod +x "$DEST/astart"
    else
        sudo cp "$ASTART" "$DEST/astart"
        sudo chmod +x "$DEST/astart"
    fi

    ok "astart installed to $DEST/astart"
    msg "You can run it as: astart"
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
# Main installer function
# -----------------------------
main() {
    echo
    msg "Starting Ai-chatbot installer"

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
