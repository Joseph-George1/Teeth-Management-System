#!/usr/bin/env bash
# =============================================================================
# restore.sh — Managed Node Restore Execution Script
# =============================================================================
# Version   : 2.0.0
# Runs ON   : Managed Node (pushed & executed by controller.sh)
# Arguments :
#   $1  backup_archive  — Path to backup .tar.gz on the node
#   $2  versions_json   — Path to versions.json on the node
#   $3  paths_json      — Path to paths.json on the node
#
# Design Principles:
#   IDEMPOTENT  — Running multiple times produces the same correct end state
#   SELF-HEALING — Detects and repairs missing/broken components automatically
#   SAFE        — Stops and logs at the exact failure point
#   AUDITABLE   — Full restore log with timestamped steps
#
# Restore Order:
#   1.  Pre-flight checks
#   2.  Stop services
#   3.  Extract backup bundle
#   4.  Restore user/group database
#   5.  Restore filesystem (configs, app files)
#   6.  Enforce package versions (self-healing)
#   7.  Restore Oracle XE (impdp)
#   8.  Restore cron jobs
#   9.  Fix permissions and ownership
#  10.  Reload/restart services
#  11.  Post-restore validation
# =============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# 0. Arguments & Defaults
# ---------------------------------------------------------------------------
BACKUP_ARCHIVE="${1:-/tmp/bkp_agent/backup.tar.gz}"
VERSIONS_JSON="${2:-/tmp/bkp_agent/versions.json}"
PATHS_JSON="${3:-/tmp/bkp_agent/paths.json}"

REMOTE_TMP="/tmp/bkp_agent"
EXTRACT_DIR="${REMOTE_TMP}/restore_extract_$$"
TS=$(date '+%Y%m%d_%H%M%S')
LOG="${REMOTE_TMP}/restore_${TS}.log"

mkdir -p "${EXTRACT_DIR}" "${REMOTE_TMP}"

# ---------------------------------------------------------------------------
# 1. Logging
# ---------------------------------------------------------------------------
log()      { echo "[$(date '+%H:%M:%S')] [INFO]  $*" | tee -a "${LOG}"; }
log_warn() { echo "[$(date '+%H:%M:%S')] [WARN]  $*" | tee -a "${LOG}"; }
log_err()  { echo "[$(date '+%H:%M:%S')] [ERROR] $*" | tee -a "${LOG}"; }
log_step() { echo "[$(date '+%H:%M:%S')] [STEP]  ── $* ──" | tee -a "${LOG}"; }
log_ok()   { echo "[$(date '+%H:%M:%S')] [OK]    ✔ $*" | tee -a "${LOG}"; }

die() {
    log_err "FATAL: $*"
    log_err "Restore stopped at this point. System may be in a partial state."
    log_err "Review log: ${LOG}"
    exit 1
}

# ---------------------------------------------------------------------------
# 2. Trap for unexpected exits
# ---------------------------------------------------------------------------
_cleanup_on_exit() {
    local rc=$?
    if [[ $rc -ne 0 ]]; then
        log_err "Restore exited unexpectedly with code ${rc}."
        log_err "Partial restore log: ${LOG}"
    fi
    # Do NOT delete extract dir on failure — needed for debugging
    [[ $rc -eq 0 ]] && rm -rf "${EXTRACT_DIR}" || true
}
trap '_cleanup_on_exit' EXIT

log "======================================================="
log "=== RESTORE AGENT START                             ==="
log "======================================================="
log "Host:    $(hostname -f)"
log "Archive: ${BACKUP_ARCHIVE}"
log "Time:    ${TS}"

# ---------------------------------------------------------------------------
# Step 1: Pre-flight checks
# ---------------------------------------------------------------------------
log_step "Step 1/11: Pre-flight checks"

[[ -f "${BACKUP_ARCHIVE}" ]] || die "Backup archive not found: ${BACKUP_ARCHIVE}"
[[ -f "${VERSIONS_JSON}"  ]] || log_warn "versions.json not found — version enforcement skipped."
[[ -f "${PATHS_JSON}"     ]] || log_warn "paths.json not found — path-specific restore limited."

# Verify tar integrity
tar --test-label -f "${BACKUP_ARCHIVE}" &>/dev/null \
    || tar -tzf "${BACKUP_ARCHIVE}" &>/dev/null \
    || die "Archive integrity check FAILED: ${BACKUP_ARCHIVE}"
log_ok "Archive integrity verified."

# Disk space check (rough: need 3× archive size)
ARCHIVE_SIZE_KB=$(du -k "${BACKUP_ARCHIVE}" | awk '{print $1}')
REQUIRED_KB=$(( ARCHIVE_SIZE_KB * 3 ))
AVAIL_KB=$(df / | awk 'NR==2{print $4}')
if [[ "${AVAIL_KB}" -lt "${REQUIRED_KB}" ]]; then
    die "Insufficient disk space. Need ~$(( REQUIRED_KB / 1024 ))MB, have $(( AVAIL_KB / 1024 ))MB."
fi
log_ok "Disk space sufficient (available: $(( AVAIL_KB / 1024 ))MB)."

# Load versions
APACHE_VER=""
ORACLE_VER=""
ORACLE_SID="XE"
ORACLE_HOME=""
ORACLE_BASE=""
EXPDP_DIR=""

if [[ -f "${VERSIONS_JSON}" ]]; then
    APACHE_VER=$(jq -r '.apache2         // empty' "${VERSIONS_JSON}")
    ORACLE_VER=$(jq -r '.oracle_xe.version // empty' "${VERSIONS_JSON}")
    ORACLE_SID=$(jq -r '.oracle_xe.sid   // "XE"'   "${VERSIONS_JSON}")
fi

if [[ -f "${PATHS_JSON}" ]]; then
    ORACLE_HOME=$(jq -r '.oracle.home     // empty' "${PATHS_JSON}")
    ORACLE_BASE=$(jq -r '.oracle.base     // empty' "${PATHS_JSON}")
    EXPDP_DIR=$(jq  -r '.oracle.expdp_dir // empty' "${PATHS_JSON}")
fi

# ---------------------------------------------------------------------------
# Step 2: Stop services gracefully
# ---------------------------------------------------------------------------
log_step "Step 2/11: Stopping services"

_safe_stop_service() {
    local svc="$1"
    if systemctl is-active --quiet "${svc}" 2>/dev/null; then
        log "Stopping ${svc}..."
        systemctl stop "${svc}" || log_warn "Could not stop ${svc}"
    else
        log "${svc} already stopped."
    fi
}

_safe_stop_service apache2
_safe_stop_service oracle-xe-21c
_safe_stop_service mysql     2>/dev/null || true
_safe_stop_service postgresql 2>/dev/null || true

log_ok "Services stopped."

# ---------------------------------------------------------------------------
# Step 3: Extract backup bundle
# ---------------------------------------------------------------------------
log_step "Step 3/11: Extracting backup bundle"

tar -xzf "${BACKUP_ARCHIVE}" --directory="${EXTRACT_DIR}" 2>>"${LOG}" \
    || die "Failed to extract backup archive."

# Identify staging directory (it's the only dir inside the extract)
STAGING=$(find "${EXTRACT_DIR}" -maxdepth 1 -mindepth 1 -type d | head -1)
[[ -d "${STAGING}" ]] || die "Could not locate staging directory in archive."
log "Staging directory: ${STAGING}"
log_ok "Archive extracted successfully."

# ---------------------------------------------------------------------------
# Step 4: Restore user/group database (idempotent merge)
# ---------------------------------------------------------------------------
log_step "Step 4/11: Restoring user/group database"

_restore_users() {
    local userdb="${STAGING}/userdb"
    [[ -d "${userdb}" ]] || { log_warn "userdb not found in backup."; return 0; }

    # Merge /etc/passwd — add missing users without overwriting existing
    while IFS=: read -r uname _ uid gid gecos home shell; do
        if ! id "${uname}" &>/dev/null; then
            log "Adding missing user: ${uname} (uid=${uid})"
            useradd \
                --uid "${uid}" \
                --gid "${gid}" 2>/dev/null \
                --comment "${gecos}" \
                --home-dir "${home}" \
                --shell "${shell}" \
                --no-create-home \
                "${uname}" 2>>"${LOG}" || log_warn "Could not add user ${uname}"
        else
            log "User ${uname} already exists — skipping."
        fi
    done < <(grep -v '^root\|^daemon\|^bin\|^sys\|^nobody' "${userdb}/passwd" 2>/dev/null || true)

    # Merge /etc/group — add missing groups
    while IFS=: read -r grp_name _ gid members; do
        if ! getent group "${grp_name}" &>/dev/null; then
            log "Adding missing group: ${grp_name} (gid=${gid})"
            groupadd --gid "${gid}" "${grp_name}" 2>>"${LOG}" || log_warn "Could not add group ${grp_name}"
        fi
    done < <(cat "${userdb}/group" 2>/dev/null || true)

    log_ok "User/group database restored."
}

_restore_users

# ---------------------------------------------------------------------------
# Step 5: Restore filesystem (configs, app data)
# ---------------------------------------------------------------------------
log_step "Step 5/11: Restoring filesystem"

_restore_filesystem() {
    local fs_archive="${STAGING}/filesystem.tar.gz"
    [[ -f "${fs_archive}" ]] || { log_warn "filesystem.tar.gz not found."; return 0; }

    log "Extracting filesystem archive to /..."
    tar \
        --extract \
        --gzip \
        --file="${fs_archive}" \
        --directory="/" \
        --overwrite \
        --ignore-failed-read \
        --warning=no-file-changed \
        --preserve-permissions \
        2>>"${LOG}" || {
            local rc=$?
            [[ $rc -eq 1 ]] && log_warn "tar extract finished with warnings — this may be normal." \
                || die "Filesystem extraction failed (exit ${rc})."
        }

    log_ok "Filesystem restored."
}

_restore_filesystem

# ---------------------------------------------------------------------------
# Step 6: Enforce package versions (self-healing + version drift correction)
# ---------------------------------------------------------------------------
log_step "Step 6/11: Enforcing package versions (self-healing)"

_ensure_package() {
    local pkg="$1" required_ver="${2:-}"

    local installed
    installed=$(dpkg -l "${pkg}" 2>/dev/null | grep '^ii' | awk '{print $3}' | head -1 || true)

    if [[ -z "${installed}" ]]; then
        log "Package ${pkg} NOT installed. Installing..."
        if [[ -n "${required_ver}" ]]; then
            apt-get install -y "${pkg}=${required_ver}" 2>>"${LOG}" \
                || apt-get install -y "${pkg}" 2>>"${LOG}" \
                || log_warn "Could not install ${pkg} version ${required_ver}."
        else
            apt-get install -y "${pkg}" 2>>"${LOG}" \
                || log_warn "Could not install ${pkg}."
        fi
        return
    fi

    # Version drift check
    if [[ -n "${required_ver}" && "${installed}" != "${required_ver}"* ]]; then
        log_warn "Version drift: ${pkg} is ${installed}, required ${required_ver}. Correcting..."
        apt-get install -y --allow-downgrades "${pkg}=${required_ver}" 2>>"${LOG}" \
            || log_warn "Downgrade failed — using installed version ${installed}."
    else
        log "${pkg}: ${installed} ✔"
    fi
}

# Update apt cache once
apt-get update -qq 2>>"${LOG}" || log_warn "apt-get update failed — continuing with cached index."

# Enforce Apache version
_ensure_package "apache2" "${APACHE_VER}"

# Restore dpkg selections if available
if [[ -f "${STAGING}/dpkg_selections.txt" ]]; then
    log "Restoring dpkg selections..."
    dpkg --set-selections < "${STAGING}/dpkg_selections.txt" 2>>"${LOG}" || true
    # Install any newly selected packages
    apt-get -y dselect-upgrade 2>>"${LOG}" || log_warn "dselect-upgrade had issues."
fi

log_ok "Package enforcement complete."

# ---------------------------------------------------------------------------
# Step 7: Restore Oracle XE Database (impdp)
# ---------------------------------------------------------------------------
log_step "Step 7/11: Restoring Oracle XE Database"

_restore_oracle() {
    local oracle_export_dir="${STAGING}/oracle_export"
    [[ -d "${oracle_export_dir}" ]] || { log_warn "oracle_export dir not found — skipping."; return 0; }

    if [[ -z "${ORACLE_HOME}" || ! -x "${ORACLE_HOME}/bin/impdp" ]]; then
        log_warn "impdp not found — skipping Oracle restore."
        return 0
    fi

    local dump_file
    dump_file=$(find "${oracle_export_dir}" -name "full_${ORACLE_SID}_*.dmp" | sort | tail -1)
    [[ -f "${dump_file}" ]] || { log_warn "No expdp dump file found — skipping Oracle restore."; return 0; }

    log "Oracle dump: $(basename "${dump_file}")"
    log "Oracle SID:  ${ORACLE_SID}"

    # Ensure Oracle services are running for restore
    systemctl start oracle-xe-21c 2>>"${LOG}" || log_warn "Could not start oracle-xe-21c"
    sleep 5  # Allow DB to open

    # Copy dump file into DATA_PUMP_DIR
    local pump_dir="${EXPDP_DIR:-${ORACLE_BASE}/admin/${ORACLE_SID}/dpdump}"
    mkdir -p "${pump_dir}"
    chown oracle:oinstall "${pump_dir}" 2>/dev/null || true
    cp "${dump_file}" "${pump_dir}/" 2>>"${LOG}" \
        || die "Could not copy dump file to pump_dir: ${pump_dir}"

    local dump_basename
    dump_basename=$(basename "${dump_file}")

    # Read Oracle SYS password from vault (no plaintext credentials in scripts)
    local oracle_sys_pass="${ORACLE_SYS_PASS:-}"
    if [[ -z "${oracle_sys_pass}" ]]; then
        local vault="/etc/bkp_vault/oracle_sys.pass"
        [[ -f "${vault}" ]] && oracle_sys_pass=$(cat "${vault}")
    fi

    log "Running impdp (full database import)..."

    if [[ -z "${oracle_sys_pass}" ]]; then
        su - oracle -c "
            export ORACLE_HOME='${ORACLE_HOME}'
            export ORACLE_SID='${ORACLE_SID}'
            export PATH=\${ORACLE_HOME}/bin:\${PATH}
            impdp '/ as sysdba' \
                FULL=Y \
                DUMPFILE='${dump_basename}' \
                DIRECTORY=DATA_PUMP_DIR \
                LOGFILE='impdp_restore_${TS}.log' \
                TABLE_EXISTS_ACTION=REPLACE \
                PARALLEL=2 \
                METRICS=YES
        " 2>&1 | tee -a "${LOG}" || {
            log_warn "impdp completed with warnings/errors — check impdp log."
        }
    else
        su - oracle -c "
            export ORACLE_HOME='${ORACLE_HOME}'
            export ORACLE_SID='${ORACLE_SID}'
            export PATH=\${ORACLE_HOME}/bin:\${PATH}
            impdp \"sys/${oracle_sys_pass}@${ORACLE_SID} as sysdba\" \
                FULL=Y \
                DUMPFILE='${dump_basename}' \
                DIRECTORY=DATA_PUMP_DIR \
                LOGFILE='impdp_restore_${TS}.log' \
                TABLE_EXISTS_ACTION=REPLACE \
                PARALLEL=2 \
                METRICS=YES
        " 2>&1 | tee -a "${LOG}" || {
            log_warn "impdp completed with warnings/errors — check impdp log."
        }
    fi

    # Restore SPFILE / PFILE if present
    local pfile="${oracle_export_dir}/init_${ORACLE_SID}.ora"
    if [[ -f "${pfile}" ]]; then
        log "Restoring SPFILE from PFILE..."
        cp "${pfile}" "${ORACLE_HOME}/dbs/" 2>>"${LOG}" || true
        su - oracle -c "
            export ORACLE_HOME='${ORACLE_HOME}'
            export ORACLE_SID='${ORACLE_SID}'
            export PATH=\${ORACLE_HOME}/bin:\${PATH}
            sqlplus -S '/ as sysdba' <<'EOF'
create spfile from pfile='${ORACLE_HOME}/dbs/$(basename "${pfile}")';
exit;
EOF
        " 2>&1 | tee -a "${LOG}" || true
    fi

    log_ok "Oracle database restore complete."
}

_restore_oracle

# ---------------------------------------------------------------------------
# Step 8: Restore cron jobs
# ---------------------------------------------------------------------------
log_step "Step 8/11: Restoring cron jobs"

_restore_cron() {
    local cron_dir="${STAGING}/cron"
    [[ -d "${cron_dir}" ]] || { log_warn "Cron backup not found — skipping."; return 0; }

    # Restore /var/spool/cron/crontabs
    if [[ -d "${cron_dir}" ]]; then
        mkdir -p /var/spool/cron/crontabs
        rsync -a --ignore-existing "${cron_dir}/" /var/spool/cron/crontabs/ 2>>"${LOG}" || true
        chown -R root:crontab /var/spool/cron/crontabs 2>/dev/null || true
        chmod 1730 /var/spool/cron/crontabs 2>/dev/null || true
    fi

    # Restore /etc/cron.d
    if [[ -d "${cron_dir}/cron.d" ]]; then
        rsync -a --ignore-existing "${cron_dir}/cron.d/" /etc/cron.d/ 2>>"${LOG}" || true
    fi

    # Restore /etc/crontab
    [[ -f "${cron_dir}/crontab" ]] && \
        cp "${cron_dir}/crontab" /etc/crontab 2>>"${LOG}" || true

    log_ok "Cron jobs restored."
}

_restore_cron

# ---------------------------------------------------------------------------
# Step 9: Fix permissions and ownership
# ---------------------------------------------------------------------------
log_step "Step 9/11: Fixing permissions and ownership"

_fix_permissions() {
    # Apache
    local web_root="/var/www"
    if [[ -d "${web_root}" ]]; then
        chown -R www-data:www-data "${web_root}" 2>/dev/null || true
        find "${web_root}" -type d -exec chmod 755 {} \; 2>/dev/null || true
        find "${web_root}" -type f -exec chmod 644 {} \; 2>/dev/null || true
        log "Permissions fixed: ${web_root}"
    fi

    # Apache config
    if [[ -d /etc/apache2 ]]; then
        chown -R root:root /etc/apache2
        chmod -R 755 /etc/apache2
        log "Permissions fixed: /etc/apache2"
    fi

    # SSH authorized_keys
    while IFS=: read -r uname _ uid _ _ home _; do
        [[ "${uid}" -lt 1000 ]] && continue
        [[ -d "${home}/.ssh" ]] || continue
        chown -R "${uname}:${uname}" "${home}/.ssh" 2>/dev/null || true
        chmod 700 "${home}/.ssh"                    2>/dev/null || true
        chmod 600 "${home}/.ssh/"*                  2>/dev/null || true
    done < /etc/passwd

    # Oracle directories
    if [[ -n "${ORACLE_BASE}" && -d "${ORACLE_BASE}" ]]; then
        chown -R oracle:oinstall "${ORACLE_BASE}" 2>/dev/null || true
        log "Permissions fixed: ${ORACLE_BASE}"
    fi

    # /etc/shadow security
    chmod 640 /etc/shadow  2>/dev/null || true
    chmod 644 /etc/passwd  2>/dev/null || true
    chmod 644 /etc/group   2>/dev/null || true

    log_ok "Permissions and ownership fixed."
}

_fix_permissions

# ---------------------------------------------------------------------------
# Step 10: Reload / restart services
# ---------------------------------------------------------------------------
log_step "Step 10/11: Starting and verifying services"

_start_service() {
    local svc="$1"
    if systemctl list-unit-files "${svc}.service" &>/dev/null; then
        log "Starting ${svc}..."
        systemctl daemon-reload 2>/dev/null || true
        systemctl enable --now "${svc}" 2>>"${LOG}" \
            || { log_warn "Could not enable/start ${svc}."; return 1; }
        sleep 2
        if systemctl is-active --quiet "${svc}"; then
            log_ok "${svc}: active"
        else
            log_warn "${svc} failed to start. Checking journal..."
            journalctl -u "${svc}" --no-pager -n 20 2>>"${LOG}" || true
            # Attempt one restart
            systemctl restart "${svc}" 2>>"${LOG}" || true
        fi
    else
        log_warn "Service ${svc} not found — skipping."
    fi
}

# Reload Apache config first (validates syntax)
if command -v apachectl &>/dev/null; then
    apachectl configtest 2>>"${LOG}" \
        && log "Apache config syntax OK." \
        || log_warn "Apache config syntax check failed — check /etc/apache2."
fi

_start_service apache2
_start_service oracle-xe-21c

# Restart cron
_start_service cron

log_ok "Services started."

# ---------------------------------------------------------------------------
# Step 11: Post-restore validation
# ---------------------------------------------------------------------------
log_step "Step 11/11: Post-restore validation"

VALIDATION_FAILED=0

_check() {
    local label="$1" result="$2" expected="$3"
    if [[ "${result}" == "${expected}" ]]; then
        log_ok "  ${label}: ${result}"
    else
        log_warn "  ${label}: ${result} (expected: ${expected})"
        VALIDATION_FAILED=$(( VALIDATION_FAILED + 1 ))
    fi
}

# Apache
APACHE_STATUS=$(systemctl is-active apache2 2>/dev/null || echo "inactive")
_check "Apache2" "${APACHE_STATUS}" "active"

# Oracle XE
ORACLE_STATUS=$(systemctl is-active oracle-xe-21c 2>/dev/null || echo "inactive")
_check "Oracle XE" "${ORACLE_STATUS}" "active"

# Oracle listener (if oracle user exists)
if id oracle &>/dev/null && [[ -n "${ORACLE_HOME}" ]]; then
    LISTENER_OK=$(su - oracle -c \
        "export ORACLE_HOME='${ORACLE_HOME}'; export PATH=\${ORACLE_HOME}/bin:\${PATH}; \
         lsnrctl status 2>/dev/null | grep -c 'ready'" || echo "0")
    if [[ "${LISTENER_OK}" -gt 0 ]]; then
        log_ok "  Oracle Listener: ready"
    else
        log_warn "  Oracle Listener: not ready"
        VALIDATION_FAILED=$(( VALIDATION_FAILED + 1 ))
    fi
fi

# Disk space
DISK_USED=$(df / | awk 'NR==2{print $5}' | tr -d '%')
if [[ "${DISK_USED}" -gt 90 ]]; then
    log_warn "  Disk usage: ${DISK_USED}% (CRITICAL)"
    VALIDATION_FAILED=$(( VALIDATION_FAILED + 1 ))
else
    log_ok "  Disk usage: ${DISK_USED}%"
fi

# Apache default page reachable (loopback)
if command -v curl &>/dev/null; then
    HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1/ 2>/dev/null || echo "000")
    if [[ "${HTTP_CODE}" =~ ^(200|301|302|403)$ ]]; then
        log_ok "  Apache HTTP response: ${HTTP_CODE}"
    else
        log_warn "  Apache HTTP response: ${HTTP_CODE}"
    fi
fi

# ---------------------------------------------------------------------------
# Finish
# ---------------------------------------------------------------------------
log "======================================================="
if [[ "${VALIDATION_FAILED}" -gt 0 ]]; then
    log_warn "Restore completed with ${VALIDATION_FAILED} validation warning(s)."
    log_warn "Review log: ${LOG}"
else
    log_ok "=== RESTORE COMPLETE — ALL VALIDATIONS PASSED ==="
fi
log "======================================================="
log "Restore log saved: ${LOG}"

exit 0
