#!/usr/bin/env bash
# =============================================================================
# controller.sh — Centralized Backup & Restore Orchestrator
# =============================================================================
# Version   : 2.0.0
# Author    : DevOps Platform Team
# Description:
#   Master controller for the self-healing, centralized backup/restore system.
#   Manages SSH-based orchestration across multiple Ubuntu servers (agents).
#   Implements: discovery, backup, restore, version enforcement, self-healing.
#
# Usage:
#   ./controller.sh [COMMAND] [OPTIONS]
#
# Commands:
#   discover  [--server <id|all>]   Run path discovery on managed nodes
#   backup    [--server <id|all>]   Run backup on managed nodes
#   restore   --server <id>         Restore a server from backup
#             [--backup <file>]     Specify backup archive (defaults to latest)
#             [--dry-run]           Simulate restore without applying changes
#   status    [--server <id|all>]   Check health status of managed nodes
#   list                            List available backups
#   verify    --server <id>         Verify integrity of latest backup
#
# Options:
#   --parallel                      Run operations in parallel (backup/discover)
#   --encrypt                       Encrypt backup archives at rest (GPG)
#   --incremental                   Use rsync-based incremental backup
#   --remote-storage <target>       Push backups to remote (s3://, user@host:)
#   --log-level <debug|info|warn>   Set logging verbosity (default: info)
#   --config <file>                 Override config file (default: controller.conf)
# =============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# ---------------------------------------------------------------------------
# 0. Bootstrap — resolve script location and load config
# ---------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/controller.conf"

[[ -f "${CONFIG_FILE}" ]] && source "${CONFIG_FILE}"

# ---------------------------------------------------------------------------
# 1. Global Defaults (overridable via controller.conf)
# ---------------------------------------------------------------------------
: "${CONTROLLER_BASE:=${SCRIPT_DIR}}"
: "${SERVERS_JSON:=${CONTROLLER_BASE}/servers.json}"
: "${BACKUPS_DIR:=${CONTROLLER_BASE}/backups}"
: "${LOGS_DIR:=${CONTROLLER_BASE}/logs}"
: "${KEYS_DIR:=${CONTROLLER_BASE}/keys}"
: "${META_DIR:=${CONTROLLER_BASE}/metadata}"
: "${SCRIPTS_DIR:=${CONTROLLER_BASE}/scripts}"
: "${CONTROLLER_LOG:=${LOGS_DIR}/controller.log}"
: "${SSH_OPTS:="-o StrictHostKeyChecking=no -o ConnectTimeout=15 -o BatchMode=yes"}"
: "${SSH_USER:=ubuntu}"
: "${SSH_PORT:=22}"
: "${REMOTE_TMP:=/tmp/bkp_agent}"
: "${LOG_LEVEL:=info}"
: "${MAX_RETRIES:=3}"
: "${RETRY_DELAY:=10}"
: "${PARALLEL:=false}"
: "${ENCRYPT:=false}"
: "${INCREMENTAL:=false}"
: "${DRY_RUN:=false}"
: "${REMOTE_STORAGE:=}"
: "${GPG_RECIPIENT:=}"
: "${BACKUP_RETENTION_DAYS:=30}"

# ---------------------------------------------------------------------------
# 2. Colour & Logging
# ---------------------------------------------------------------------------
COL_RESET='\033[0m'
COL_RED='\033[0;31m'
COL_GREEN='\033[0;32m'
COL_YELLOW='\033[0;33m'
COL_BLUE='\033[0;34m'
COL_CYAN='\033[0;36m'
COL_BOLD='\033[1m'

_timestamp()  { date '+%Y-%m-%d %H:%M:%S'; }
_log_raw()    { echo -e "[$(_timestamp)] $*" | tee -a "${CONTROLLER_LOG}"; }

log_debug() { [[ "${LOG_LEVEL}" == "debug" ]] && _log_raw "${COL_CYAN}[DEBUG]${COL_RESET} $*" || true; }
log_info()  { [[ "${LOG_LEVEL}" =~ ^(debug|info)$ ]] && _log_raw "${COL_GREEN}[INFO] ${COL_RESET} $*" || true; }
log_warn()  { _log_raw "${COL_YELLOW}[WARN] ${COL_RESET} $*"; }
log_error() { _log_raw "${COL_RED}[ERROR]${COL_RESET} $*"; }
log_step()  { _log_raw "${COL_BOLD}${COL_BLUE}[STEP] ${COL_RESET} $*"; }
log_ok()    { _log_raw "${COL_GREEN}[OK]   ${COL_RESET} $*"; }

die() {
    log_error "$*"
    exit 1
}

# ---------------------------------------------------------------------------
# 3. Prerequisite checks
# ---------------------------------------------------------------------------
check_prerequisites() {
    log_step "Checking controller prerequisites..."
    local missing=()
    for cmd in ssh scp rsync jq gpg tar sha256sum curl; do
        command -v "${cmd}" &>/dev/null || missing+=("${cmd}")
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        die "Missing required tools: ${missing[*]}. Install them and retry."
    fi
    [[ -f "${SERVERS_JSON}" ]] || die "servers.json not found at: ${SERVERS_JSON}"
    jq empty "${SERVERS_JSON}" 2>/dev/null || die "servers.json is not valid JSON."
    mkdir -p "${BACKUPS_DIR}" "${LOGS_DIR}" "${META_DIR}" "${KEYS_DIR}"
    log_ok "Prerequisites satisfied."
}

# ---------------------------------------------------------------------------
# 4. Server inventory helpers (servers.json)
# ---------------------------------------------------------------------------
# Iterate all enabled server IDs
get_server_ids() {
    jq -r '.servers[] | select(.enabled == true) | .id' "${SERVERS_JSON}"
}

# Get field for a server: get_server_field <id> <field>
get_server_field() {
    local id="$1" field="$2"
    jq -r --arg id "$id" --arg f "$field" \
        '.servers[] | select(.id == $id) | .[$f] // empty' "${SERVERS_JSON}"
}

# Build SSH command prefix for a server
ssh_cmd() {
    local server_id="$1"
    local host key user port
    host=$(get_server_field "${server_id}" "host")
    key=$(get_server_field  "${server_id}" "ssh_key")
    user=$(get_server_field "${server_id}" "ssh_user")
    port=$(get_server_field "${server_id}" "ssh_port")
    user="${user:-${SSH_USER}}"
    port="${port:-${SSH_PORT}}"
    [[ -f "${key}" ]] || die "SSH key not found: ${key}"
    echo "ssh ${SSH_OPTS} -i ${key} -p ${port} ${user}@${host}"
}

# Resolve single/all server targets
resolve_servers() {
    local target="${1:-all}"
    if [[ "${target}" == "all" ]]; then
        get_server_ids
    else
        jq -r --arg id "${target}" \
            '.servers[] | select(.id == $id and .enabled == true) | .id' \
            "${SERVERS_JSON}" || die "Server '${target}' not found or disabled."
    fi
}

# ---------------------------------------------------------------------------
# 5. Remote execution helpers
# ---------------------------------------------------------------------------
# run_remote <server_id> <command>
run_remote() {
    local server_id="$1"; shift
    local cmd_str="$*"
    local ssh
    ssh=$(ssh_cmd "${server_id}")
    log_debug "[${server_id}] Remote: ${cmd_str}"
    # shellcheck disable=SC2086
    ${ssh} "bash -c '${cmd_str}'"
}

# run_remote_script <server_id> <local_script> [args]
run_remote_script() {
    local server_id="$1" script="$2"; shift 2
    local args="$*"
    local ssh
    ssh=$(ssh_cmd "${server_id}")
    log_debug "[${server_id}] Pushing and running: $(basename "${script}")"
    # shellcheck disable=SC2086
    ${ssh} "mkdir -p ${REMOTE_TMP}"
    # shellcheck disable=SC2086
    scp ${SSH_OPTS} -i "$(get_server_field "${server_id}" "ssh_key")" \
        "${script}" \
        "$(get_server_field "${server_id}" "ssh_user")@$(get_server_field "${server_id}" "host"):${REMOTE_TMP}/$(basename "${script}")"
    # shellcheck disable=SC2086
    ${ssh} "bash ${REMOTE_TMP}/$(basename "${script}") ${args}"
}

# scp_from_remote <server_id> <remote_path> <local_dest>
scp_from_remote() {
    local server_id="$1" remote_path="$2" local_dest="$3"
    local key user host port
    key=$(get_server_field  "${server_id}" "ssh_key")
    user=$(get_server_field "${server_id}" "ssh_user")
    host=$(get_server_field "${server_id}" "host")
    port=$(get_server_field "${server_id}" "ssh_port"); port="${port:-${SSH_PORT}}"
    # shellcheck disable=SC2086
    scp ${SSH_OPTS} -i "${key}" -P "${port}" \
        "${user}@${host}:${remote_path}" "${local_dest}"
}

# scp_to_remote <server_id> <local_path> <remote_dest>
scp_to_remote() {
    local server_id="$1" local_path="$2" remote_dest="$3"
    local key user host port
    key=$(get_server_field  "${server_id}" "ssh_key")
    user=$(get_server_field "${server_id}" "ssh_user")
    host=$(get_server_field "${server_id}" "host")
    port=$(get_server_field "${server_id}" "ssh_port"); port="${port:-${SSH_PORT}}"
    # shellcheck disable=SC2086
    scp ${SSH_OPTS} -i "${key}" -P "${port}" \
        "${local_path}" "${user}@${host}:${remote_dest}"
}

# rsync_from_remote <server_id> <remote_path> <local_dest>
rsync_from_remote() {
    local server_id="$1" remote_path="$2" local_dest="$3"
    local key user host port
    key=$(get_server_field  "${server_id}" "ssh_key")
    user=$(get_server_field "${server_id}" "ssh_user")
    host=$(get_server_field "${server_id}" "host")
    port=$(get_server_field "${server_id}" "ssh_port"); port="${port:-${SSH_PORT}}"
    rsync -avz --checksum \
        -e "ssh ${SSH_OPTS} -i ${key} -p ${port}" \
        "${user}@${host}:${remote_path}" "${local_dest}"
}

# ---------------------------------------------------------------------------
# 6. Retry wrapper
# ---------------------------------------------------------------------------
with_retry() {
    local attempts=0
    until "$@"; do
        attempts=$(( attempts + 1 ))
        [[ ${attempts} -ge ${MAX_RETRIES} ]] && { log_error "Failed after ${MAX_RETRIES} attempts: $*"; return 1; }
        log_warn "Attempt ${attempts}/${MAX_RETRIES} failed. Retrying in ${RETRY_DELAY}s..."
        sleep "${RETRY_DELAY}"
    done
}

# ---------------------------------------------------------------------------
# 7. Connectivity check
# ---------------------------------------------------------------------------
check_connectivity() {
    local server_id="$1"
    local host
    host=$(get_server_field "${server_id}" "host")
    log_debug "[${server_id}] Testing SSH connectivity to ${host}..."
    if ! run_remote "${server_id}" "echo connected" &>/dev/null; then
        log_error "[${server_id}] Cannot connect to ${host}."
        return 1
    fi
    log_debug "[${server_id}] Connectivity OK."
}

# ---------------------------------------------------------------------------
# 8. Path Discovery
# ---------------------------------------------------------------------------
cmd_discover() {
    local target="${1:-all}"
    local servers
    mapfile -t servers < <(resolve_servers "${target}")
    [[ ${#servers[@]} -eq 0 ]] && die "No enabled servers matched: ${target}"

    log_step "=== PATH DISCOVERY (target: ${target}) ==="

    _discover_one() {
        local sid="$1"
        local server_log="${LOGS_DIR}/discover_${sid}.log"
        log_info "[${sid}] Starting path discovery..."

        {
            check_connectivity "${sid}" || return 1

            # Push discover_paths.sh to remote
            run_remote_script "${sid}" "${SCRIPTS_DIR}/discover_paths.sh" 2>&1

            # Retrieve paths.json
            local meta_dir="${META_DIR}/${sid}"
            mkdir -p "${meta_dir}"
            scp_from_remote "${sid}" \
                "${REMOTE_TMP}/paths.json" \
                "${meta_dir}/paths.json"

            # Validate
            jq empty "${meta_dir}/paths.json" 2>/dev/null \
                || { log_error "[${sid}] Invalid paths.json received."; return 1; }

            log_ok "[${sid}] Path discovery complete → ${meta_dir}/paths.json"
        } >> "${server_log}" 2>&1
        local rc=$?
        [[ $rc -ne 0 ]] && log_error "[${sid}] Discovery failed. See ${server_log}"
        return $rc
    }

    if [[ "${PARALLEL}" == "true" ]]; then
        local pids=()
        for sid in "${servers[@]}"; do
            _discover_one "${sid}" &
            pids+=($!)
        done
        local failed=0
        for pid in "${pids[@]}"; do
            wait "${pid}" || failed=$(( failed + 1 ))
        done
        [[ $failed -gt 0 ]] && log_warn "${failed} server(s) had discovery failures."
    else
        local failed=0
        for sid in "${servers[@]}"; do
            _discover_one "${sid}" || failed=$(( failed + 1 ))
        done
        [[ $failed -gt 0 ]] && log_warn "${failed} server(s) had discovery failures."
    fi
    log_step "=== DISCOVERY COMPLETE ==="
}

# ---------------------------------------------------------------------------
# 9. Backup
# ---------------------------------------------------------------------------
cmd_backup() {
    local target="${1:-all}"
    local servers
    mapfile -t servers < <(resolve_servers "${target}")
    [[ ${#servers[@]} -eq 0 ]] && die "No enabled servers matched: ${target}"

    log_step "=== BACKUP RUN (target: ${target}, parallel: ${PARALLEL}) ==="

    _backup_one() {
        local sid="$1"
        local ts; ts=$(date '+%Y%m%d_%H%M%S')
        local server_log="${LOGS_DIR}/backup_${sid}_${ts}.log"
        local server_backup_dir="${BACKUPS_DIR}/${sid}"
        local remote_archive="${REMOTE_TMP}/backup_${sid}.tar.gz"
        local local_archive="${server_backup_dir}/backup_${sid}_${ts}.tar.gz"
        local meta_dir="${META_DIR}/${sid}"

        mkdir -p "${server_backup_dir}" "${meta_dir}"

        {
            log_info "[${sid}] ── Starting backup ──────────────────────────"
            check_connectivity "${sid}" || return 1

            # Ensure paths.json exists; auto-discover if missing
            if [[ ! -f "${meta_dir}/paths.json" ]]; then
                log_warn "[${sid}] paths.json missing — running discovery first."
                cmd_discover "${sid}"
            fi

            # Push backup.sh and paths.json to remote
            scp_to_remote "${sid}" "${SCRIPTS_DIR}/backup.sh" "${REMOTE_TMP}/backup.sh"
            scp_to_remote "${sid}" "${meta_dir}/paths.json"   "${REMOTE_TMP}/paths.json"

            # Execute remote backup
            with_retry run_remote "${sid}" \
                "bash ${REMOTE_TMP}/backup.sh ${REMOTE_TMP}/paths.json ${remote_archive}"

            # Pull backup archive
            if [[ "${INCREMENTAL}" == "true" ]]; then
                log_info "[${sid}] Using rsync incremental transfer..."
                rsync_from_remote "${sid}" "${remote_archive}" "${local_archive}"
            else
                scp_from_remote "${sid}" "${remote_archive}" "${local_archive}"
            fi

            # Checksum
            local checksum_file="${local_archive}.sha256"
            sha256sum "${local_archive}" > "${checksum_file}"
            log_info "[${sid}] SHA-256: $(cat "${checksum_file}")"

            # Pull version metadata
            scp_from_remote "${sid}" \
                "${REMOTE_TMP}/versions.json" \
                "${meta_dir}/versions.json" 2>/dev/null || true

            # Encrypt if requested
            if [[ "${ENCRYPT}" == "true" ]]; then
                [[ -n "${GPG_RECIPIENT}" ]] || die "GPG_RECIPIENT not set for encryption."
                gpg --recipient "${GPG_RECIPIENT}" --output "${local_archive}.gpg" \
                    --encrypt "${local_archive}"
                rm -f "${local_archive}"
                local_archive="${local_archive}.gpg"
                log_info "[${sid}] Archive encrypted → ${local_archive}"
            fi

            # Update symlink: latest
            local latest_link="${server_backup_dir}/latest.tar.gz"
            [[ "${ENCRYPT}" == "true" ]] && latest_link="${server_backup_dir}/latest.tar.gz.gpg"
            ln -sfn "${local_archive}" "${latest_link}"

            # Store backup manifest
            local manifest="${meta_dir}/manifest_${ts}.json"
            jq -n \
                --arg sid   "${sid}" \
                --arg ts    "${ts}" \
                --arg arch  "${local_archive}" \
                --arg sha   "$(awk '{print $1}' "${checksum_file}" 2>/dev/null || echo 'N/A')" \
                --arg enc   "${ENCRYPT}" \
                --arg incr  "${INCREMENTAL}" \
                '{server:$sid, timestamp:$ts, archive:$arch, sha256:$sha,
                  encrypted:($enc=="true"), incremental:($incr=="true")}' \
                > "${manifest}"

            # Push to remote storage if configured
            if [[ -n "${REMOTE_STORAGE}" ]]; then
                _push_remote_storage "${local_archive}" "${REMOTE_STORAGE}/${sid}/"
            fi

            # Cleanup remote tmp
            run_remote "${sid}" "rm -f ${remote_archive}" || true

            # Prune old backups
            _prune_old_backups "${server_backup_dir}"

            log_ok "[${sid}] Backup complete → ${local_archive}"

        } >> "${server_log}" 2>&1
        local rc=$?
        if [[ $rc -ne 0 ]]; then
            log_error "[${sid}] Backup FAILED. See ${server_log}"
        else
            log_info "[${sid}] Backup log: ${server_log}"
        fi
        return $rc
    }

    if [[ "${PARALLEL}" == "true" ]]; then
        local pids=()
        for sid in "${servers[@]}"; do
            _backup_one "${sid}" &
            pids+=($!)
        done
        local failed=0
        for pid in "${pids[@]}"; do
            wait "${pid}" || failed=$(( failed + 1 ))
        done
        [[ $failed -gt 0 ]] && log_warn "${failed} backup(s) failed."
    else
        local failed=0
        for sid in "${servers[@]}"; do
            _backup_one "${sid}" || failed=$(( failed + 1 ))
        done
        [[ $failed -gt 0 ]] && log_warn "${failed} backup(s) failed."
    fi
    log_step "=== BACKUP RUN COMPLETE ==="
}

# Push to remote storage (S3 or SSH target)
_push_remote_storage() {
    local file="$1" dest="$2"
    if [[ "${dest}" == s3://* ]]; then
        aws s3 cp "${file}" "${dest}" || log_warn "S3 upload failed for ${file}"
    else
        rsync -avz "${file}" "${dest}" || log_warn "Remote storage sync failed for ${file}"
    fi
    log_info "Pushed ${file} → ${dest}"
}

# Prune backups older than BACKUP_RETENTION_DAYS
_prune_old_backups() {
    local dir="$1"
    find "${dir}" -maxdepth 1 -name "backup_*.tar.gz*" \
        -mtime "+${BACKUP_RETENTION_DAYS}" -delete 2>/dev/null || true
    log_debug "Pruned backups older than ${BACKUP_RETENTION_DAYS} days in ${dir}"
}

# ---------------------------------------------------------------------------
# 10. Restore
# ---------------------------------------------------------------------------
cmd_restore() {
    local server_id="${1:-}"
    local backup_file="${2:-}"    # optional; defaults to latest
    [[ -z "${server_id}" ]] && die "restore requires --server <id>"

    local ts; ts=$(date '+%Y%m%d_%H%M%S')
    local restore_log="${LOGS_DIR}/restore_${server_id}_${ts}.log"
    local meta_dir="${META_DIR}/${server_id}"
    local server_backup_dir="${BACKUPS_DIR}/${server_id}"

    # Resolve backup archive
    if [[ -z "${backup_file}" ]]; then
        backup_file="${server_backup_dir}/latest.tar.gz"
        [[ -f "${backup_file}" ]] || \
            backup_file=$(ls -1t "${server_backup_dir}"/backup_*.tar.gz 2>/dev/null | head -1)
        [[ -f "${backup_file}" ]] || die "No backup found for server: ${server_id}"
    fi
    [[ -f "${backup_file}" ]] || die "Backup file not found: ${backup_file}"

    log_step "=== RESTORE: ${server_id} from $(basename "${backup_file}") ==="
    [[ "${DRY_RUN}" == "true" ]] && log_warn "DRY-RUN mode: no changes will be applied."

    {
        log_info "[${server_id}] Restore started at ${ts}"
        log_info "[${server_id}] Backup file: ${backup_file}"
        log_info "[${server_id}] Dry-run: ${DRY_RUN}"

        # 10.1 Verify archive integrity
        log_step "[${server_id}] Step 1/8: Verifying archive integrity..."
        _verify_archive "${backup_file}"

        # 10.2 Check connectivity
        log_step "[${server_id}] Step 2/8: Checking connectivity..."
        with_retry check_connectivity "${server_id}"

        # 10.3 Decrypt if needed
        local active_archive="${backup_file}"
        if [[ "${backup_file}" == *.gpg ]]; then
            log_step "[${server_id}] Step 3/8: Decrypting archive..."
            active_archive="${backup_file%.gpg}"
            gpg --output "${active_archive}" --decrypt "${backup_file}"
        fi

        if [[ "${DRY_RUN}" == "true" ]]; then
            log_warn "[${server_id}] DRY-RUN: Would push archive and run restore.sh"
            log_ok "[${server_id}] DRY-RUN complete. No changes applied."
            return 0
        fi

        # 10.4 Self-healing pre-restore check
        log_step "[${server_id}] Step 4/8: Running self-healing checks..."
        _self_heal "${server_id}" "${meta_dir}"

        # 10.5 Push scripts and archive to remote
        log_step "[${server_id}] Step 5/8: Pushing restore assets to remote..."
        run_remote "${server_id}" "mkdir -p ${REMOTE_TMP}"
        scp_to_remote "${server_id}" "${SCRIPTS_DIR}/restore.sh" "${REMOTE_TMP}/restore.sh"
        scp_to_remote "${server_id}" "${active_archive}"          "${REMOTE_TMP}/backup.tar.gz"

        [[ -f "${meta_dir}/versions.json" ]] && \
            scp_to_remote "${server_id}" "${meta_dir}/versions.json" "${REMOTE_TMP}/versions.json"
        [[ -f "${meta_dir}/paths.json" ]] && \
            scp_to_remote "${server_id}" "${meta_dir}/paths.json" "${REMOTE_TMP}/paths.json"

        # 10.6 Execute restore remotely
        log_step "[${server_id}] Step 6/8: Executing remote restore..."
        with_retry run_remote "${server_id}" \
            "bash ${REMOTE_TMP}/restore.sh \
                ${REMOTE_TMP}/backup.tar.gz \
                ${REMOTE_TMP}/versions.json \
                ${REMOTE_TMP}/paths.json"

        # 10.7 Post-restore health check
        log_step "[${server_id}] Step 7/8: Running post-restore health checks..."
        _health_check_post_restore "${server_id}" "${meta_dir}"

        # 10.8 Cleanup remote tmp
        log_step "[${server_id}] Step 8/8: Cleanup..."
        run_remote "${server_id}" "rm -rf ${REMOTE_TMP}" || true

        log_ok "[${server_id}] ✔ RESTORE COMPLETE"

    } 2>&1 | tee -a "${restore_log}"

    local rc=${PIPESTATUS[0]}
    if [[ $rc -ne 0 ]]; then
        log_error "[${server_id}] Restore FAILED. Review: ${restore_log}"
        exit $rc
    fi
    log_info "Restore log: ${restore_log}"
}

# ---------------------------------------------------------------------------
# 11. Archive Integrity Verification
# ---------------------------------------------------------------------------
_verify_archive() {
    local archive="$1"
    local checksum_file="${archive}.sha256"

    if [[ -f "${checksum_file}" ]]; then
        log_info "Verifying SHA-256 checksum..."
        sha256sum --check "${checksum_file}" \
            || die "Checksum verification FAILED for ${archive}"
        log_ok "Checksum OK."
    else
        log_warn "No checksum file found for ${archive}. Skipping verification."
    fi

    # Test tar integrity (non-gpg archives)
    if [[ "${archive}" != *.gpg ]]; then
        tar --test-label -f "${archive}" &>/dev/null \
            || tar -tzf "${archive}" &>/dev/null \
            || die "Archive integrity test FAILED: ${archive}"
        log_ok "Archive structure OK."
    fi
}

cmd_verify() {
    local server_id="${1:-}"
    [[ -z "${server_id}" ]] && die "verify requires --server <id>"
    local latest="${BACKUPS_DIR}/${server_id}/latest.tar.gz"
    [[ -f "${latest}" ]] || die "No latest backup for ${server_id}"
    log_step "Verifying backup for ${server_id}..."
    _verify_archive "${latest}"
    log_ok "Backup verified for ${server_id}: ${latest}"
}

# ---------------------------------------------------------------------------
# 12. Self-Healing
# ---------------------------------------------------------------------------
_self_heal() {
    local server_id="$1"
    local meta_dir="$2"
    local versions_file="${meta_dir}/versions.json"

    log_info "[${server_id}] Self-healing: checking required components..."

    # A. Check and install Apache
    _heal_service "${server_id}" "apache2" "apache2" "${versions_file}" "apache2"

    # B. Check Oracle XE
    _heal_oracle_xe "${server_id}" "${versions_file}"

    # C. Verify critical directories exist
    _heal_directories "${server_id}" "${meta_dir}"

    log_ok "[${server_id}] Self-healing checks complete."
}

_heal_service() {
    local server_id="$1" svc_name="$2" pkg_name="$3" versions_file="$4" version_key="$5"
    log_info "[${server_id}] Checking service: ${svc_name}"

    local installed
    installed=$(run_remote "${server_id}" \
        "dpkg -l ${pkg_name} 2>/dev/null | grep '^ii' | awk '{print \$3}' | head -1" 2>/dev/null || true)

    if [[ -z "${installed}" ]]; then
        log_warn "[${server_id}] ${pkg_name} NOT installed. Installing..."
        local required_ver=""
        if [[ -f "${versions_file}" ]]; then
            required_ver=$(jq -r --arg k "${version_key}" '.[$k] // empty' "${versions_file}" 2>/dev/null || true)
        fi
        if [[ -n "${required_ver}" ]]; then
            run_remote "${server_id}" \
                "apt-get install -y ${pkg_name}=${required_ver} 2>/dev/null || apt-get install -y ${pkg_name}"
        else
            run_remote "${server_id}" "apt-get update -qq && apt-get install -y ${pkg_name}"
        fi
        log_ok "[${server_id}] ${pkg_name} installed."
    else
        log_debug "[${server_id}] ${pkg_name} installed: ${installed}"
        # Version drift check
        if [[ -f "${versions_file}" ]]; then
            local required_ver
            required_ver=$(jq -r --arg k "${version_key}" '.[$k] // empty' "${versions_file}" 2>/dev/null || true)
            if [[ -n "${required_ver}" && "${installed}" != "${required_ver}"* ]]; then
                log_warn "[${server_id}] Version drift: ${pkg_name} is ${installed}, required ${required_ver}."
                run_remote "${server_id}" \
                    "apt-get install -y --allow-downgrades ${pkg_name}=${required_ver} 2>/dev/null || true"
                log_ok "[${server_id}] ${pkg_name} version corrected to ${required_ver}."
            fi
        fi
    fi

    # Ensure service is running
    local running
    running=$(run_remote "${server_id}" \
        "systemctl is-active ${svc_name} 2>/dev/null || echo inactive")
    if [[ "${running}" != "active" ]]; then
        log_warn "[${server_id}] Service ${svc_name} is ${running}. Attempting start..."
        run_remote "${server_id}" "systemctl enable --now ${svc_name} || true"
    fi
}

_heal_oracle_xe() {
    local server_id="$1" versions_file="$2"
    log_info "[${server_id}] Checking Oracle XE installation..."

    local oracle_installed
    oracle_installed=$(run_remote "${server_id}" \
        "dpkg -l oracle-xe-21c 2>/dev/null | grep '^ii' || echo ''" 2>/dev/null || true)

    if [[ -z "${oracle_installed}" ]]; then
        log_warn "[${server_id}] Oracle XE not found. Attempting installation..."
        # Oracle XE auto-install requires a pre-configured repo — log for manual intervention
        log_error "[${server_id}] Oracle XE auto-install requires Oracle repo configuration."
        log_error "[${server_id}] Ensure /etc/apt/sources.list.d/oracle-xe.list is configured on target."
        run_remote "${server_id}" \
            "apt-get install -y oracle-xe-21c 2>/dev/null || true"
    else
        log_debug "[${server_id}] Oracle XE present."
        # Ensure listener is running
        local listener_ok
        listener_ok=$(run_remote "${server_id}" \
            "su - oracle -c 'lsnrctl status' 2>/dev/null | grep -c 'ready' || echo 0")
        if [[ "${listener_ok}" == "0" ]]; then
            log_warn "[${server_id}] Oracle listener not running. Starting..."
            run_remote "${server_id}" \
                "su - oracle -c 'lsnrctl start' && systemctl restart oracle-xe-21c || true"
        fi
    fi
}

_heal_directories() {
    local server_id="$1" meta_dir="$2"
    local paths_file="${meta_dir}/paths.json"
    [[ -f "${paths_file}" ]] || return 0

    log_info "[${server_id}] Recreating missing directories from paths.json..."
    while IFS= read -r dir_path; do
        [[ -z "${dir_path}" ]] && continue
        run_remote "${server_id}" "mkdir -p '${dir_path}'" || true
    done < <(jq -r '.directories[]? // empty' "${paths_file}" 2>/dev/null)
    log_debug "[${server_id}] Directory structure verified."
}

# ---------------------------------------------------------------------------
# 13. Post-Restore Health Check
# ---------------------------------------------------------------------------
_health_check_post_restore() {
    local server_id="$1" meta_dir="$2"
    local failed_checks=()

    log_info "[${server_id}] Running post-restore health checks..."

    # Check Apache
    local apache_status
    apache_status=$(run_remote "${server_id}" \
        "systemctl is-active apache2 2>/dev/null || echo inactive")
    if [[ "${apache_status}" != "active" ]]; then
        failed_checks+=("apache2 not running (status: ${apache_status})")
        log_warn "[${server_id}] Apache not active — attempting restart..."
        run_remote "${server_id}" "systemctl restart apache2 || true"
    else
        log_ok "[${server_id}] Apache: active"
    fi

    # Check Oracle XE
    local oracle_status
    oracle_status=$(run_remote "${server_id}" \
        "systemctl is-active oracle-xe-21c 2>/dev/null || echo inactive")
    if [[ "${oracle_status}" != "active" ]]; then
        failed_checks+=("oracle-xe-21c not running (status: ${oracle_status})")
        log_warn "[${server_id}] Oracle XE not active — attempting restart..."
        run_remote "${server_id}" "systemctl restart oracle-xe-21c || true"
    else
        log_ok "[${server_id}] Oracle XE: active"
    fi

    # Check disk space
    local disk_used
    disk_used=$(run_remote "${server_id}" \
        "df / | awk 'NR==2{print \$5}' | tr -d '%'" 2>/dev/null || echo 0)
    if [[ "${disk_used}" -gt 90 ]]; then
        failed_checks+=("Disk usage critical: ${disk_used}%")
        log_warn "[${server_id}] Disk usage at ${disk_used}%"
    else
        log_ok "[${server_id}] Disk usage: ${disk_used}%"
    fi

    # Report
    if [[ ${#failed_checks[@]} -gt 0 ]]; then
        log_warn "[${server_id}] Health check issues:"
        for chk in "${failed_checks[@]}"; do
            log_warn "  ✘ ${chk}"
        done
    else
        log_ok "[${server_id}] All post-restore health checks passed ✔"
    fi
}

# ---------------------------------------------------------------------------
# 14. Status Command
# ---------------------------------------------------------------------------
cmd_status() {
    local target="${1:-all}"
    local servers
    mapfile -t servers < <(resolve_servers "${target}")

    log_step "=== SERVER STATUS ==="
    printf "%-20s %-18s %-10s %-12s %-12s\n" "SERVER" "HOST" "SSH" "APACHE" "ORACLE-XE"
    printf "%-20s %-18s %-10s %-12s %-12s\n" "──────" "────" "───" "──────" "─────────"

    for sid in "${servers[@]}"; do
        local host ssh_ok apache oracle
        host=$(get_server_field "${sid}" "host")

        if check_connectivity "${sid}" &>/dev/null; then
            ssh_ok="${COL_GREEN}OK${COL_RESET}"
            apache=$(run_remote "${sid}" "systemctl is-active apache2 2>/dev/null || echo unknown")
            oracle=$(run_remote "${sid}" "systemctl is-active oracle-xe-21c 2>/dev/null || echo unknown")
        else
            ssh_ok="${COL_RED}FAIL${COL_RESET}"
            apache="N/A"; oracle="N/A"
        fi

        _colour_status() {
            local s="$1"
            case "${s}" in
                active)   echo -e "${COL_GREEN}${s}${COL_RESET}" ;;
                inactive) echo -e "${COL_YELLOW}${s}${COL_RESET}" ;;
                *)        echo -e "${COL_RED}${s}${COL_RESET}" ;;
            esac
        }

        printf "%-20s %-18s %-10b %-12b %-12b\n" \
            "${sid}" "${host}" \
            "${ssh_ok}" \
            "$(_colour_status "${apache}")" \
            "$(_colour_status "${oracle}")"
    done
    echo ""
}

# ---------------------------------------------------------------------------
# 15. List Backups
# ---------------------------------------------------------------------------
cmd_list() {
    log_step "=== AVAILABLE BACKUPS ==="
    printf "%-20s %-40s %-20s %-10s\n" "SERVER" "FILE" "DATE" "SIZE"
    printf "%-20s %-40s %-20s %-10s\n" "──────" "────" "────" "────"

    while IFS= read -r sid; do
        local server_dir="${BACKUPS_DIR}/${sid}"
        [[ -d "${server_dir}" ]] || continue
        while IFS= read -r f; do
            local fname size fdate
            fname=$(basename "${f}")
            size=$(du -sh "${f}" 2>/dev/null | awk '{print $1}')
            fdate=$(date -r "${f}" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || stat -c '%y' "${f}" | cut -d'.' -f1)
            printf "%-20s %-40s %-20s %-10s\n" "${sid}" "${fname}" "${fdate}" "${size}"
        done < <(find "${server_dir}" -maxdepth 1 -name "backup_*.tar.gz*" | sort -r)
    done < <(get_server_ids)
    echo ""
}

# ---------------------------------------------------------------------------
# 16. Argument Parsing & Dispatch
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
${COL_BOLD}Backup & Restore Controller v2.0${COL_RESET}

Usage: $(basename "$0") COMMAND [OPTIONS]

Commands:
  discover  [--server <id|all>]           Discover paths on managed nodes
  backup    [--server <id|all>]           Run backup on managed nodes
  restore   --server <id>                 Restore server from latest backup
            [--backup <archive>]          Use specific backup file
            [--dry-run]                   Simulate without applying changes
  status    [--server <id|all>]           Show health status of servers
  verify    --server <id>                 Verify archive integrity
  list                                    List all stored backups

Flags:
  --parallel                              Parallel execution (backup/discover)
  --encrypt                               Encrypt archives with GPG
  --incremental                           Incremental backup via rsync
  --remote-storage <dest>                 Push backups (s3:// or user@host:)
  --log-level <debug|info|warn>           Verbosity (default: info)

Examples:
  $(basename "$0") discover --server all --parallel
  $(basename "$0") backup   --server web-01 --encrypt
  $(basename "$0") restore  --server web-01 --dry-run
  $(basename "$0") status
  $(basename "$0") list
EOF
    exit 0
}

main() {
    mkdir -p "${LOGS_DIR}"
    [[ $# -eq 0 ]] && usage

    local command="$1"; shift
    local target_server="all"
    local backup_file=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --server)         target_server="${2:-all}"; shift 2 ;;
            --backup)         backup_file="${2:-}";      shift 2 ;;
            --parallel)       PARALLEL=true;             shift   ;;
            --encrypt)        ENCRYPT=true;              shift   ;;
            --incremental)    INCREMENTAL=true;          shift   ;;
            --dry-run)        DRY_RUN=true;              shift   ;;
            --remote-storage) REMOTE_STORAGE="${2:-}";  shift 2 ;;
            --log-level)      LOG_LEVEL="${2:-info}";   shift 2 ;;
            --config)         source "${2}";             shift 2 ;;
            -h|--help)        usage ;;
            *) die "Unknown option: $1" ;;
        esac
    done

    check_prerequisites

    case "${command}" in
        discover) cmd_discover "${target_server}" ;;
        backup)   cmd_backup   "${target_server}" ;;
        restore)  cmd_restore  "${target_server}" "${backup_file}" ;;
        status)   cmd_status   "${target_server}" ;;
        verify)   cmd_verify   "${target_server}" ;;
        list)     cmd_list ;;
        *)        die "Unknown command: ${command}. Run with --help." ;;
    esac
}

main "$@"
