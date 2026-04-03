#!/usr/bin/env bash
# =============================================================================
# discover_paths.sh — Remote Path Discovery Agent
# =============================================================================
# Version   : 2.0.0
# Runs ON: Managed Node (pushed and executed by controller.sh)
# Purpose:
#   Auto-discovers all paths, configs, and application data that must be
#   included in a backup. Outputs a structured paths.json consumed by
#   controller.sh and backup.sh.
#
# Output: ${REMOTE_TMP}/paths.json  (default: /tmp/bkp_agent/paths.json)
#
# Discovered categories:
#   - Application directories (web roots, app homes)
#   - /etc configuration files and directories
#   - Apache / HTTPD virtual host configs
#   - Oracle XE data, config, and wallet paths
#   - System users and home directories
#   - Installed packages (dpkg snapshot)
#   - Running services
#   - Cron jobs
#   - SSL/TLS certificates
# =============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# 0. Configuration
# ---------------------------------------------------------------------------
REMOTE_TMP="${REMOTE_TMP:-/tmp/bkp_agent}"
OUTPUT="${REMOTE_TMP}/paths.json"
HOSTNAME_VAL=$(hostname -f 2>/dev/null || hostname)
TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

mkdir -p "${REMOTE_TMP}"

# ---------------------------------------------------------------------------
# 1. Logging (local to managed node)
# ---------------------------------------------------------------------------
LOG="${REMOTE_TMP}/discover.log"
log() { echo "[$(date '+%H:%M:%S')] $*" | tee -a "${LOG}"; }

# ---------------------------------------------------------------------------
# 2. Helper: safe find with error suppression
# ---------------------------------------------------------------------------
safe_find() { find "$@" 2>/dev/null || true; }

# ---------------------------------------------------------------------------
# 3. Application directories
# ---------------------------------------------------------------------------
log "Discovering application directories..."

APP_DIRS=()

# Standard web roots
for d in /var/www /srv/www /opt/apps /opt/web /home/*/public_html; do
    [[ -d "${d}" ]] && APP_DIRS+=("${d}")
done

# Custom app directories (heuristic: directories owned by non-system users)
while IFS= read -r d; do
    [[ -d "${d}" ]] && APP_DIRS+=("${d}")
done < <(safe_find /opt /srv /app -maxdepth 2 -type d -not -path '*/\.*' 2>/dev/null | head -50)

# Deduplicate
mapfile -t APP_DIRS < <(printf '%s\n' "${APP_DIRS[@]}" | sort -u)

# ---------------------------------------------------------------------------
# 4. /etc configs
# ---------------------------------------------------------------------------
log "Discovering /etc configurations..."

ETC_PATHS=("/etc")

# Specific high-value config dirs
for p in \
    /etc/apache2 /etc/httpd \
    /etc/nginx \
    /etc/ssh/sshd_config \
    /etc/hosts /etc/hostname /etc/timezone /etc/localtime \
    /etc/environment /etc/profile /etc/profile.d \
    /etc/sudoers /etc/sudoers.d \
    /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/crontab \
    /etc/logrotate.d \
    /etc/ssl /etc/pki \
    /etc/systemd/system \
    /etc/network /etc/netplan \
    /etc/fstab /etc/mtab; do
    [[ -e "${p}" ]] && ETC_PATHS+=("${p}")
done

mapfile -t ETC_PATHS < <(printf '%s\n' "${ETC_PATHS[@]}" | sort -u)

# ---------------------------------------------------------------------------
# 5. Apache config paths
# ---------------------------------------------------------------------------
log "Discovering Apache paths..."

APACHE_PATHS=()
APACHE_VHOSTS=()
APACHE_LOGS=()

for base in /etc/apache2 /etc/httpd; do
    [[ -d "${base}" ]] || continue
    APACHE_PATHS+=("${base}")
    # Virtual hosts
    while IFS= read -r f; do
        APACHE_VHOSTS+=("${f}")
    done < <(safe_find "${base}" -name "*.conf" -type f)
done

# Apache log dirs
for d in /var/log/apache2 /var/log/httpd; do
    [[ -d "${d}" ]] && APACHE_LOGS+=("${d}")
done

# Web document roots referenced in vhosts
if command -v apachectl &>/dev/null || command -v apache2ctl &>/dev/null; then
    local_ctl=$(command -v apachectl 2>/dev/null || command -v apache2ctl 2>/dev/null)
    while IFS= read -r root; do
        [[ -d "${root}" ]] && APP_DIRS+=("${root}")
    done < <("${local_ctl}" -S 2>/dev/null | grep -oP 'DocumentRoot \K\S+' || true)
fi

# Apache modules and enabled sites
for d in \
    /etc/apache2/sites-available \
    /etc/apache2/sites-enabled \
    /etc/apache2/mods-available \
    /etc/apache2/mods-enabled \
    /etc/apache2/conf-available \
    /etc/apache2/conf-enabled; do
    [[ -d "${d}" ]] && APACHE_PATHS+=("${d}")
done

mapfile -t APACHE_PATHS < <(printf '%s\n' "${APACHE_PATHS[@]}" | sort -u)
mapfile -t APACHE_VHOSTS < <(printf '%s\n' "${APACHE_VHOSTS[@]}" | sort -u)

# ---------------------------------------------------------------------------
# 6. Oracle XE paths
# ---------------------------------------------------------------------------
log "Discovering Oracle XE paths..."

ORACLE_PATHS=()
ORACLE_DATA_DIRS=()
ORACLE_DIAG_DIRS=()
ORACLE_HOME=""
ORACLE_BASE=""
ORACLE_SID=""
ORACLE_VERSION=""

# Detect ORACLE_HOME from environment or known locations
if id oracle &>/dev/null; then
    ORACLE_HOME=$(su - oracle -c 'echo $ORACLE_HOME' 2>/dev/null || true)
    ORACLE_BASE=$(su - oracle -c 'echo $ORACLE_BASE' 2>/dev/null || true)
    ORACLE_SID=$(su  - oracle -c 'echo $ORACLE_SID'  2>/dev/null || true)
fi

# Fallback search
if [[ -z "${ORACLE_HOME}" ]]; then
    for d in \
        /opt/oracle/product/21c/dbhomeXE \
        /opt/oracle/product/19c/dbhomeXE \
        /u01/app/oracle/product/21c/dbhomeXE \
        /u01/app/oracle/product/19c/dbhomeXE; do
        [[ -d "${d}" ]] && ORACLE_HOME="${d}" && break
    done
fi

if [[ -z "${ORACLE_BASE}" ]]; then
    for d in /opt/oracle /u01/app/oracle; do
        [[ -d "${d}" ]] && ORACLE_BASE="${d}" && break
    done
fi

ORACLE_SID="${ORACLE_SID:-XE}"

# Collect Oracle paths
for p in \
    "${ORACLE_HOME}" \
    "${ORACLE_BASE}" \
    "${ORACLE_BASE}/oradata" \
    "${ORACLE_BASE}/oradata/${ORACLE_SID}" \
    "${ORACLE_BASE}/fast_recovery_area" \
    "${ORACLE_BASE}/admin" \
    "${ORACLE_BASE}/cfgtoollogs" \
    "${ORACLE_BASE}/diag" \
    "/etc/oratab" \
    "/etc/oraInst.loc" \
    "/opt/oracle" \
    "/opt/oracle/homes"; do
    [[ -e "${p}" ]] && ORACLE_PATHS+=("${p}")
done

# Oracle wallet
for d in \
    "${ORACLE_BASE}/admin/${ORACLE_SID}/wallet" \
    "/etc/oracle/wallet" \
    "${ORACLE_HOME}/wallet"; do
    [[ -d "${d}" ]] && ORACLE_PATHS+=("${d}")
done

# Data files (tablespace files — critical for restore)
if [[ -d "${ORACLE_BASE}/oradata/${ORACLE_SID}" ]]; then
    while IFS= read -r f; do
        ORACLE_DATA_DIRS+=("$(dirname "${f}")")
    done < <(safe_find "${ORACLE_BASE}/oradata/${ORACLE_SID}" \
        \( -name "*.dbf" -o -name "*.ctl" -o -name "*.log" \) -type f)
fi

# Data pump directory (expdp output)
ORACLE_EXPDP_DIR=""
if id oracle &>/dev/null; then
    ORACLE_EXPDP_DIR=$(su - oracle -c \
        "sqlplus -S / as sysdba <<'EOF'
set pagesize 0 feedback off
select directory_path from dba_directories where directory_name='DATA_PUMP_DIR';
exit;
EOF" 2>/dev/null | tr -d '[:space:]' || true)
fi
[[ -z "${ORACLE_EXPDP_DIR}" ]] && ORACLE_EXPDP_DIR="${ORACLE_BASE}/admin/${ORACLE_SID}/dpdump"
[[ -d "${ORACLE_EXPDP_DIR}" ]] || ORACLE_EXPDP_DIR="/opt/oracle/admin/${ORACLE_SID}/dpdump"

mapfile -t ORACLE_PATHS    < <(printf '%s\n' "${ORACLE_PATHS[@]}"    | sort -u)
mapfile -t ORACLE_DATA_DIRS< <(printf '%s\n' "${ORACLE_DATA_DIRS[@]}"| sort -u)

# ---------------------------------------------------------------------------
# 7. User home directories
# ---------------------------------------------------------------------------
log "Discovering user home directories..."

USER_HOMES=()
while IFS=: read -r uname _ uid _ _ home _; do
    [[ "${uid}" -ge 1000 ]] || continue   # skip system users
    [[ "${home}" == /root ]] && continue   # handled separately
    [[ -d "${home}" ]] && USER_HOMES+=("${home}")
done < /etc/passwd

mapfile -t USER_HOMES < <(printf '%s\n' "${USER_HOMES[@]}" | sort -u)

# ---------------------------------------------------------------------------
# 8. Installed packages snapshot
# ---------------------------------------------------------------------------
log "Capturing installed packages..."

PACKAGES_FILE="${REMOTE_TMP}/packages.txt"
dpkg --get-selections > "${PACKAGES_FILE}" 2>/dev/null || true
APT_SOURCES_FILE="${REMOTE_TMP}/apt_sources.tar.gz"
tar -czf "${APT_SOURCES_FILE}" /etc/apt/sources.list /etc/apt/sources.list.d/ 2>/dev/null || true

# ---------------------------------------------------------------------------
# 9. Running services snapshot
# ---------------------------------------------------------------------------
log "Capturing running services..."

SERVICES_FILE="${REMOTE_TMP}/services.txt"
systemctl list-units --type=service --state=running --no-pager --no-legend \
    | awk '{print $1}' > "${SERVICES_FILE}" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 10. Cron jobs
# ---------------------------------------------------------------------------
log "Capturing cron jobs..."

CRON_FILE="${REMOTE_TMP}/crontabs.tar.gz"
tar -czf "${CRON_FILE}" \
    /var/spool/cron/crontabs 2>/dev/null \
    /etc/cron.d 2>/dev/null \
    /etc/crontab 2>/dev/null || true

# ---------------------------------------------------------------------------
# 11. SSL certificates
# ---------------------------------------------------------------------------
log "Discovering SSL certificates..."

SSL_PATHS=()
for d in /etc/ssl /etc/pki /etc/letsencrypt /etc/certs; do
    [[ -d "${d}" ]] && SSL_PATHS+=("${d}")
done
# Apache SSL cert paths from vhost configs
if [[ ${#APACHE_VHOSTS[@]} -gt 0 ]]; then
    while IFS= read -r cert; do
        [[ -f "${cert}" ]] && SSL_PATHS+=("$(dirname "${cert}")")
    done < <(grep -h 'SSLCertificate' "${APACHE_VHOSTS[@]}" 2>/dev/null | \
             awk '{print $2}' | sort -u || true)
fi

mapfile -t SSL_PATHS < <(printf '%s\n' "${SSL_PATHS[@]}" | sort -u)

# ---------------------------------------------------------------------------
# 12. Assemble paths.json
# ---------------------------------------------------------------------------
log "Assembling paths.json..."

# Convert bash arrays to JSON arrays
_to_json_array() {
    local arr=("$@")
    printf '%s\n' "${arr[@]:-}" | grep -v '^$' | jq -R . | jq -s .
}

APP_JSON=$(     _to_json_array "${APP_DIRS[@]:-}")
ETC_JSON=$(     _to_json_array "${ETC_PATHS[@]:-}")
APACHE_JSON=$(  _to_json_array "${APACHE_PATHS[@]:-}")
VHOST_JSON=$(   _to_json_array "${APACHE_VHOSTS[@]:-}")
ORACLE_JSON=$(  _to_json_array "${ORACLE_PATHS[@]:-}")
ORACLE_DATA_JSON=$(_to_json_array "${ORACLE_DATA_DIRS[@]:-}")
USER_JSON=$(    _to_json_array "${USER_HOMES[@]:-}")
SSL_JSON=$(     _to_json_array "${SSL_PATHS[@]:-}")
LOG_JSON=$(     _to_json_array "${APACHE_LOGS[@]:-}")

jq -n \
    --arg      host           "${HOSTNAME_VAL}" \
    --arg      ts             "${TS}" \
    --arg      oracle_home    "${ORACLE_HOME:-}" \
    --arg      oracle_base    "${ORACLE_BASE:-}" \
    --arg      oracle_sid     "${ORACLE_SID:-XE}" \
    --arg      oracle_expdp   "${ORACLE_EXPDP_DIR:-}" \
    --argjson  app_dirs       "${APP_JSON}" \
    --argjson  etc_paths      "${ETC_JSON}" \
    --argjson  apache_paths   "${APACHE_JSON}" \
    --argjson  apache_vhosts  "${VHOST_JSON}" \
    --argjson  oracle_paths   "${ORACLE_JSON}" \
    --argjson  oracle_data    "${ORACLE_DATA_JSON}" \
    --argjson  user_homes     "${USER_JSON}" \
    --argjson  ssl_paths      "${SSL_JSON}" \
    --argjson  log_paths      "${LOG_JSON}" \
    '{
        "host":        $host,
        "discovered_at": $ts,
        "oracle": {
            "home":       $oracle_home,
            "base":       $oracle_base,
            "sid":        $oracle_sid,
            "expdp_dir":  $oracle_expdp
        },
        "directories": ($app_dirs + $etc_paths + $oracle_paths + $user_homes + $ssl_paths),
        "paths": {
            "app_dirs":      $app_dirs,
            "etc":           $etc_paths,
            "apache":        $apache_paths,
            "apache_vhosts": $apache_vhosts,
            "oracle":        $oracle_paths,
            "oracle_data":   $oracle_data,
            "user_homes":    $user_homes,
            "ssl":           $ssl_paths,
            "log_dirs":      $log_paths
        },
        "auxiliary_files": {
            "packages":  "/tmp/bkp_agent/packages.txt",
            "services":  "/tmp/bkp_agent/services.txt",
            "crontabs":  "/tmp/bkp_agent/crontabs.tar.gz",
            "apt_sources": "/tmp/bkp_agent/apt_sources.tar.gz"
        }
    }' > "${OUTPUT}"

log "paths.json written to: ${OUTPUT}"
log "Discovery complete."
cat "${OUTPUT}"
