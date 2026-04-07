#!/usr/bin/env bash
# =============================================================================
# backup.sh — Managed Node Backup Execution Script
# =============================================================================
# Version   : 2.0.0
# Runs ON   : Managed Node (pushed & executed by controller.sh)
# Arguments :
#   $1  paths_json   — Path to paths.json on the node (default: /tmp/bkp_agent/paths.json)
#   $2  output_archive — Destination tar.gz path    (default: /tmp/bkp_agent/backup_<host>.tar.gz)
#
# Responsibilities:
#   1. Read paths from paths.json
#   2. Archive all discovered directories & files
#   3. Run Oracle expdp (Data Pump) export
#   4. Collect version metadata (versions.json)
#   5. Bundle everything into a single archive
#   6. Write checksums
# =============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# 0. Arguments & Defaults
# ---------------------------------------------------------------------------
PATHS_JSON="${1:-/tmp/bkp_agent/paths.json}"
OUTPUT_ARCHIVE="${2:-/tmp/bkp_agent/backup_$(hostname -s).tar.gz}"
REMOTE_TMP="$(dirname "${OUTPUT_ARCHIVE}")"
STAGING="${REMOTE_TMP}/staging_$$"
TS=$(date '+%Y%m%d_%H%M%S')
LOG="${REMOTE_TMP}/backup_${TS}.log"

mkdir -p "${STAGING}" "${REMOTE_TMP}"

# ---------------------------------------------------------------------------
# 1. Logging
# ---------------------------------------------------------------------------
log()      { echo "[$(date '+%H:%M:%S')] [INFO]  $*" | tee -a "${LOG}"; }
log_warn() { echo "[$(date '+%H:%M:%S')] [WARN]  $*" | tee -a "${LOG}"; }
log_err()  { echo "[$(date '+%H:%M:%S')] [ERROR] $*" | tee -a "${LOG}"; }
die()      { log_err "$*"; exit 1; }

log "=== BACKUP AGENT START ==="
log "Host:    $(hostname -f)"
log "Archive: ${OUTPUT_ARCHIVE}"
log "Staging: ${STAGING}"

# ---------------------------------------------------------------------------
# 2. Validate inputs
# ---------------------------------------------------------------------------
[[ -f "${PATHS_JSON}" ]] || die "paths.json not found: ${PATHS_JSON}"
jq empty "${PATHS_JSON}" 2>/dev/null || die "paths.json is not valid JSON"

ORACLE_HOME=$(jq -r '.oracle.home  // empty' "${PATHS_JSON}")
ORACLE_BASE=$(jq -r '.oracle.base  // empty' "${PATHS_JSON}")
ORACLE_SID=$(jq  -r '.oracle.sid   // "XE"'  "${PATHS_JSON}")
EXPDP_DIR=$(jq   -r '.oracle.expdp_dir // empty' "${PATHS_JSON}")

log "Oracle SID:  ${ORACLE_SID:-<not detected>}"
log "Oracle HOME: ${ORACLE_HOME:-<not detected>}"

# ---------------------------------------------------------------------------
# 3. Collect version metadata → versions.json
# ---------------------------------------------------------------------------
log "Collecting version metadata..."

_get_version() {
    local pkg="$1"
    dpkg -l "${pkg}" 2>/dev/null | grep '^ii' | awk '{print $3}' | head -1 || echo ""
}

_get_service_version() {
    "$@" --version 2>&1 | head -1 || echo "unknown"
}

APACHE_VER=$(_get_version apache2)
APACHE_VER="${APACHE_VER:-$(_get_version httpd 2>/dev/null || echo '')}"

PHP_VER=$(php --version 2>/dev/null | head -1 | awk '{print $2}' || echo "")
PYTHON3_VER=$(python3 --version 2>/dev/null | awk '{print $2}' || echo "")
JAVA_VER=$(java -version 2>&1 | head -1 | tr -d '"' | awk '{print $3}' || echo "")
NODEJS_VER=$(node --version 2>/dev/null | tr -d 'v' || echo "")
MYSQL_VER=$(_get_version mysql-server 2>/dev/null || echo "")
POSTGRES_VER=$(_get_version postgresql 2>/dev/null || echo "")

# Oracle version
ORACLE_VER=""
if [[ -n "${ORACLE_HOME}" && -x "${ORACLE_HOME}/bin/sqlplus" ]]; then
    ORACLE_VER=$(su - oracle -c \
        "${ORACLE_HOME}/bin/sqlplus -S / as sysdba <<'EOF'
set pagesize 0 feedback off heading off
select version from v\$instance;
exit;
EOF" 2>/dev/null | tr -d '[:space:]' || true)
fi
[[ -z "${ORACLE_VER}" ]] && ORACLE_VER=$(_get_version oracle-xe-21c 2>/dev/null || echo "")

OS_ID=$(grep '^ID=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
OS_VER=$(grep '^VERSION_ID=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')
KERNEL=$(uname -r)

jq -n \
    --arg ts          "${TS}" \
    --arg host        "$(hostname -f)" \
    --arg os_id       "${OS_ID:-ubuntu}" \
    --arg os_ver      "${OS_VER:-}" \
    --arg kernel      "${KERNEL}" \
    --arg apache      "${APACHE_VER}" \
    --arg php         "${PHP_VER}" \
    --arg python3     "${PYTHON3_VER}" \
    --arg java        "${JAVA_VER}" \
    --arg nodejs      "${NODEJS_VER}" \
    --arg mysql       "${MYSQL_VER}" \
    --arg postgres    "${POSTGRES_VER}" \
    --arg oracle      "${ORACLE_VER}" \
    --arg oracle_sid  "${ORACLE_SID}" \
    '{
        "backup_timestamp": $ts,
        "host": $host,
        "os": { "id": $os_id, "version": $os_ver, "kernel": $kernel },
        "apache2":    $apache,
        "php":        $php,
        "python3":    $python3,
        "java":       $java,
        "nodejs":     $nodejs,
        "mysql":      $mysql,
        "postgresql": $postgres,
        "oracle_xe": {
            "version": $oracle,
            "sid":     $oracle_sid
        }
    }' > "${REMOTE_TMP}/versions.json"

log "versions.json written."

# ---------------------------------------------------------------------------
# 4. Collect dpkg package list
# ---------------------------------------------------------------------------
log "Capturing dpkg package list..."
dpkg --get-selections > "${STAGING}/dpkg_selections.txt" 2>/dev/null || true
apt-mark showmanual    > "${STAGING}/apt_manual.txt"      2>/dev/null || true

# ---------------------------------------------------------------------------
# 5. Collect running services list
# ---------------------------------------------------------------------------
log "Capturing systemd service states..."
systemctl list-units --type=service --no-pager --no-legend \
    > "${STAGING}/systemd_services.txt" 2>/dev/null || true
systemctl list-unit-files --type=service --no-pager --no-legend \
    > "${STAGING}/systemd_enabled.txt" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 6. Collect crontabs
# ---------------------------------------------------------------------------
log "Collecting cron jobs..."
mkdir -p "${STAGING}/cron"
cp -a /var/spool/cron/crontabs/. "${STAGING}/cron/"   2>/dev/null || true
cp    /etc/crontab                "${STAGING}/cron/"   2>/dev/null || true
cp -a /etc/cron.d/.               "${STAGING}/cron/cron.d/" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 7. Collect /etc/passwd, /etc/shadow, /etc/group (user database)
# ---------------------------------------------------------------------------
log "Capturing user/group database..."
mkdir -p "${STAGING}/userdb"
cp /etc/passwd  "${STAGING}/userdb/" 2>/dev/null || true
cp /etc/shadow  "${STAGING}/userdb/" 2>/dev/null || true
cp /etc/group   "${STAGING}/userdb/" 2>/dev/null || true
cp /etc/gshadow "${STAGING}/userdb/" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 8. Oracle XE Data Pump Export (expdp)
# ---------------------------------------------------------------------------
_run_oracle_backup() {
    if [[ -z "${ORACLE_HOME}" || ! -x "${ORACLE_HOME}/bin/expdp" ]]; then
        log_warn "Oracle expdp not found — skipping Oracle backup."
        return 0
    fi

    log "Starting Oracle Data Pump export (expdp)..."

    local dump_dir="${EXPDP_DIR:-${ORACLE_BASE}/admin/${ORACLE_SID}/dpdump}"
    mkdir -p "${dump_dir}" 2>/dev/null || true
    # Ensure dump dir ownership
    chown -R oracle:oinstall "${dump_dir}" 2>/dev/null || true

    local dump_file="full_${ORACLE_SID}_${TS}.dmp"
    local log_file="expdp_${ORACLE_SID}_${TS}.log"

    # Read Oracle credentials from secure vault (environment or vault file)
    # NEVER store plaintext passwords in scripts
    local oracle_sys_pass="${ORACLE_SYS_PASS:-}"
    if [[ -z "${oracle_sys_pass}" ]]; then
        # Try reading from secure vault file (root:root 600)
        local vault="/etc/bkp_vault/oracle_sys.pass"
        [[ -f "${vault}" ]] && oracle_sys_pass=$(cat "${vault}")
    fi

    if [[ -z "${oracle_sys_pass}" ]]; then
        log_warn "Oracle SYS password not available. Using OS authentication (/ as sysdba)."
        # Use OS auth — requires oracle user to run expdp
        su - oracle -c "
            export ORACLE_HOME='${ORACLE_HOME}'
            export ORACLE_SID='${ORACLE_SID}'
            export PATH=\${ORACLE_HOME}/bin:\${PATH}
            expdp '/ as sysdba' \
                FULL=Y \
                DUMPFILE='${dump_file}' \
                LOGFILE='${log_file}' \
                DIRECTORY=DATA_PUMP_DIR \
                COMPRESSION=ALL \
                REUSE_DUMPFILES=YES \
                PARALLEL=2
        " 2>&1 | tee -a "${LOG}" || { log_warn "expdp failed — check expdp log."; return 1; }
    else
        su - oracle -c "
            export ORACLE_HOME='${ORACLE_HOME}'
            export ORACLE_SID='${ORACLE_SID}'
            export PATH=\${ORACLE_HOME}/bin:\${PATH}
            expdp \"sys/${oracle_sys_pass}@${ORACLE_SID} as sysdba\" \
                FULL=Y \
                DUMPFILE='${dump_file}' \
                LOGFILE='${log_file}' \
                DIRECTORY=DATA_PUMP_DIR \
                COMPRESSION=ALL \
                REUSE_DUMPFILES=YES \
                PARALLEL=2
        " 2>&1 | tee -a "${LOG}" || { log_warn "expdp failed — check expdp log."; return 1; }
    fi

    # Copy dump and log into staging
    mkdir -p "${STAGING}/oracle_export"
    cp "${dump_dir}/${dump_file}"  "${STAGING}/oracle_export/" 2>/dev/null || true
    cp "${dump_dir}/${log_file}"   "${STAGING}/oracle_export/" 2>/dev/null || true

    # Also grab control files and SPFILE
    su - oracle -c "
        export ORACLE_HOME='${ORACLE_HOME}'
        export ORACLE_SID='${ORACLE_SID}'
        export PATH=\${ORACLE_HOME}/bin:\${PATH}
        sqlplus -S '/ as sysdba' <<'EOF'
set pagesize 0 feedback off heading off
-- Backup SPFILE to PFILE
create pfile='${STAGING}/oracle_export/init_${ORACLE_SID}.ora' from spfile;
-- Backup controlfile trace
alter database backup controlfile to trace as '${STAGING}/oracle_export/controlfile_trace_${ORACLE_SID}.sql' reuse;
exit;
EOF
    " 2>&1 | tee -a "${LOG}" || true

    log "Oracle export complete → ${STAGING}/oracle_export/"
}

_run_oracle_backup

# ---------------------------------------------------------------------------
# 9. Archive all discovered paths
# ---------------------------------------------------------------------------
log "Archiving discovered paths..."

PATHS_ARCHIVE="${STAGING}/filesystem.tar.gz"
EXCLUDE_LIST="${STAGING}/excludes.txt"

# Build exclude list
cat > "${EXCLUDE_LIST}" <<'EXCLUDES'
/proc
/sys
/dev
/run
/tmp
/var/tmp
/lost+found
/media
/mnt
*.tmp
*.swp
*.pid
*.sock
/var/cache/apt
/var/lib/apt/lists
/tmp/bkp_agent
EXCLUDES

# Collect all include paths from paths.json
INCLUDE_PATHS=()
while IFS= read -r p; do
    [[ -e "${p}" ]] && INCLUDE_PATHS+=("${p}") || true
done < <(jq -r '.directories[]? // empty' "${PATHS_JSON}")

if [[ ${#INCLUDE_PATHS[@]} -eq 0 ]]; then
    log_warn "No valid paths found in paths.json — archiving /etc and /var/www as fallback."
    INCLUDE_PATHS=("/etc" "/var/www")
fi

log "Archiving ${#INCLUDE_PATHS[@]} path(s)..."

# Build tar include file
printf '%s\n' "${INCLUDE_PATHS[@]}" > "${STAGING}/includes.txt"

tar \
    --create \
    --gzip \
    --file="${PATHS_ARCHIVE}" \
    --exclude-from="${EXCLUDE_LIST}" \
    --ignore-failed-read \
    --warning=no-file-changed \
    --files-from="${STAGING}/includes.txt" \
    2>> "${LOG}" || {
        # Non-fatal: tar exits 1 if files changed during archive (normal)
        local rc=$?
        [[ $rc -eq 1 ]] && log_warn "tar finished with warnings (exit 1) — likely file changes during backup." \
            || die "tar failed with exit code ${rc}"
    }

log "Filesystem archive: ${PATHS_ARCHIVE}"

# ---------------------------------------------------------------------------
# 10. Bundle staging into final archive
# ---------------------------------------------------------------------------
log "Assembling final backup bundle..."

# Copy metadata into staging root
cp "${PATHS_JSON}"               "${STAGING}/paths.json"        2>/dev/null || true
cp "${REMOTE_TMP}/versions.json" "${STAGING}/versions.json"     2>/dev/null || true

# Manifest
cat > "${STAGING}/MANIFEST.txt" <<MANIFEST
BACKUP MANIFEST
===============
Host:       $(hostname -f)
Timestamp:  ${TS}
Archive:    $(basename "${OUTPUT_ARCHIVE}")
Contents:
  - filesystem.tar.gz      : All discovered directories
  - oracle_export/         : Oracle Data Pump dump + controlfile
  - dpkg_selections.txt    : Installed packages
  - apt_manual.txt         : Manually installed packages
  - systemd_services.txt   : Running services
  - systemd_enabled.txt    : Enabled services
  - cron/                  : All crontabs
  - userdb/                : passwd, shadow, group
  - paths.json             : Discovered paths
  - versions.json          : Component version metadata
MANIFEST

tar \
    --create \
    --gzip \
    --file="${OUTPUT_ARCHIVE}" \
    --directory="$(dirname "${STAGING}")" \
    "$(basename "${STAGING}")" \
    2>> "${LOG}"

log "Final bundle: ${OUTPUT_ARCHIVE} ($(du -sh "${OUTPUT_ARCHIVE}" | awk '{print $1}'))"

# ---------------------------------------------------------------------------
# 11. Checksum
# ---------------------------------------------------------------------------
sha256sum "${OUTPUT_ARCHIVE}" > "${OUTPUT_ARCHIVE}.sha256"
log "SHA-256: $(cat "${OUTPUT_ARCHIVE}.sha256")"

# ---------------------------------------------------------------------------
# 12. Cleanup staging
# ---------------------------------------------------------------------------
rm -rf "${STAGING}"
log "=== BACKUP AGENT COMPLETE ==="
