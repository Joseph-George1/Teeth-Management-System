# Centralized Self-Healing Backup & Restore Platform

> **Architecture**: Controller–Agent | **Target OS**: Ubuntu 20.04 / 22.04 LTS  
> **Version**: 2.0.0 | **Auth**: SSH Key-Based Only

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Directory Structure](#directory-structure)
4. [Quick Start](#quick-start)
5. [Configuration](#configuration)
6. [Commands Reference](#commands-reference)
7. [Workflow Deep Dive](#workflow-deep-dive)
8. [Self-Healing Mechanism](#self-healing-mechanism)
9. [Oracle XE Backup & Restore](#oracle-xe-backup--restore)
10. [Security](#security)
11. [Scheduling & Automation](#scheduling--automation)
12. [Logging](#logging)
13. [Troubleshooting](#troubleshooting)
14. [Design Decisions](#design-decisions)

---

## Overview

This platform provides **centralized, automated, self-healing backup and restore** for fleets of Ubuntu servers running Apache and Oracle XE workloads. It implements a Controller–Agent model where a single master node orchestrates all operations over SSH — no agent daemon required on managed nodes.

**Core guarantees:**

| Property | Description |
|---|---|
| **Idempotent** | Restore can be run multiple times; always produces the same correct state |
| **Self-healing** | Detects and repairs missing packages, wrong versions, broken services |
| **Zero-plaintext** | No passwords in scripts; uses OS-auth and vault files |
| **Auditable** | Every operation produces structured, timestamped logs |
| **Resilient** | Retry logic, failure isolation, checksum verification |

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    MASTER CONTROLLER                     │
│                                                         │
│  controller.sh ──┬── discover  ──► discover_paths.sh   │
│                  ├── backup    ──► backup.sh            │
│                  ├── restore   ──► restore.sh           │
│                  └── status / verify / list             │
│                                                         │
│  Storage:                                               │
│    backups/     ← backup archives (.tar.gz)            │
│    metadata/    ← paths.json, versions.json, manifests │
│    logs/        ← controller.log, per-server logs      │
│    keys/        ← SSH private keys (chmod 600)         │
└──────────────────────────┬──────────────────────────────┘
                           │  SSH (key-auth only)
           ┌───────────────┼───────────────┐
           │               │               │
    ┌──────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
    │   web-01    │ │   db-01     │ │   app-01    │
    │             │ │             │ │             │
    │ Apache      │ │ Oracle XE   │ │ Apache +    │
    │             │ │             │ │ Oracle XE   │
    └─────────────┘ └─────────────┘ └─────────────┘
      Managed Nodes (Ubuntu) — no agent daemon required
```

### Data Flow

```
BACKUP:
  Controller → SSH → push backup.sh + paths.json → Node
  Node: archive paths + expdp Oracle → tar.gz
  Controller ← SCP ← backup_<server>.tar.gz + versions.json
  Controller: checksum → store → [encrypt] → [push remote]

RESTORE:
  Controller: verify archive → self-heal check → push archive + restore.sh
  Node: stop services → extract → restore FS → enforce versions
        → impdp Oracle → fix permissions → start services → validate
  Controller ← result (success/failure log)
```

---

## Directory Structure

```
/opt/backup-platform/
├── controller.sh          ← Main orchestrator (run this)
├── controller.conf        ← Configuration overrides
├── servers.json           ← Server inventory
├── setup.sh               ← One-time setup script
│
├── scripts/               ← Scripts pushed to managed nodes
│   ├── discover_paths.sh
│   ├── backup.sh
│   └── restore.sh
│
├── keys/                  ← SSH private keys (chmod 700 dir, 600 files)
│   ├── web-01.pem
│   ├── db-01.pem
│   └── app-01.pem
│
├── backups/               ← Backup archives
│   ├── web-01/
│   │   ├── backup_web-01_20250115_020015.tar.gz
│   │   ├── backup_web-01_20250115_020015.tar.gz.sha256
│   │   └── latest.tar.gz  ← symlink to most recent
│   └── db-01/
│       └── ...
│
├── metadata/              ← Per-server metadata
│   ├── app-01/
│   │   ├── paths.json         ← Discovered paths
│   │   ├── versions.json      ← Component versions at backup time
│   │   └── manifest_*.json    ← Backup manifests
│   └── ...
│
└── logs/                  ← Centralized logs
    ├── controller.log
    ├── backup_web-01_20250115_020015.log
    ├── restore_web-01_20250115_030001.log
    └── discover_app-01.log

/etc/bkp_vault/
└── oracle_sys.pass        ← Oracle SYS password (root:root, chmod 600)
```

---

## Quick Start

### 1. Deploy the platform

```bash
# Clone or copy the platform to the controller node
cp -r backup-platform/ /opt/backup-platform/
cd /opt/backup-platform/

# Run setup (installs deps, creates dirs, sets up cron & logrotate)
sudo bash setup.sh /opt/backup-platform
```

### 2. Add your servers

Edit `servers.json`:
```json
{
  "id": "web-01",
  "host": "10.0.1.10",
  "ssh_user": "ubuntu",
  "ssh_port": 22,
  "ssh_key": "/opt/backup-platform/keys/web-01.pem",
  "enabled": true
}
```

Place SSH private keys:
```bash
cp web-01.pem /opt/backup-platform/keys/web-01.pem
chmod 600 /opt/backup-platform/keys/web-01.pem
```

### 3. Set Oracle SYS password (if using Oracle XE)

```bash
echo 'YourSysPassword' | sudo tee /etc/bkp_vault/oracle_sys.pass
sudo chmod 600 /etc/bkp_vault/oracle_sys.pass
sudo chown root:root /etc/bkp_vault/oracle_sys.pass
```

### 4. Test and run

```bash
# Check connectivity to all servers
./controller.sh status

# Discover paths on all servers
./controller.sh discover --server all

# Run backup on all servers
./controller.sh backup --server all

# List available backups
./controller.sh list

# Restore a server (dry-run first!)
./controller.sh restore --server app-01 --dry-run
./controller.sh restore --server app-01
```

---

## Configuration

Edit `controller.conf` to override defaults:

```bash
# Core paths
CONTROLLER_BASE="/opt/backup-platform"
LOG_LEVEL="info"              # debug | info | warn

# Behaviour
PARALLEL=false                # true = parallel backup/discover
ENCRYPT=false                 # true = GPG encrypt archives
INCREMENTAL=false             # true = rsync incremental transfer
BACKUP_RETENTION_DAYS=30      # auto-prune backups older than N days

# Remote storage (optional)
REMOTE_STORAGE="s3://my-bucket/backups"    # or "user@host:/path"
GPG_RECIPIENT="ops@example.com"            # required if ENCRYPT=true

# Retry behaviour
MAX_RETRIES=3
RETRY_DELAY=10
```

---

## Commands Reference

```
./controller.sh COMMAND [OPTIONS]

Commands:
  discover  [--server <id|all>]      Discover paths on managed nodes
  backup    [--server <id|all>]      Run backup on managed nodes
  restore   --server <id>            Restore from latest backup
            [--backup <archive>]     Use specific backup file
            [--dry-run]              Simulate without making changes
  status    [--server <id|all>]      Health status of servers
  verify    --server <id>            Verify archive checksum + integrity
  list                               List all stored backups

Flags (combinable):
  --parallel          Parallel execution across servers
  --encrypt           Encrypt archives with GPG
  --incremental       Incremental rsync transfer
  --remote-storage    Push to S3 or remote SSH
  --log-level         debug | info | warn
  --dry-run           Simulate restore safely
  --config <file>     Use alternate config file
```

---

## Workflow Deep Dive

### Discovery (`discover_paths.sh`)

Runs on each managed node. Detects:
- App directories under `/var/www`, `/srv`, `/opt`
- All of `/etc` plus high-value config paths
- Apache vhost configs, enabled sites/modules
- Oracle XE: `$ORACLE_HOME`, `$ORACLE_BASE`, data pump dir, wallet
- User home directories (UID ≥ 1000)
- SSL/TLS certificate paths

Output `paths.json` is pulled to `metadata/<server>/paths.json`.

### Backup (`backup.sh`)

Executed on managed node. Steps:
1. Read `paths.json` — enumerate all paths to archive
2. Collect `versions.json` — snapshot of all component versions
3. Capture dpkg selections, systemd states, crontabs, user DB
4. Run `expdp` — full Oracle XE data pump export with `COMPRESSION=ALL`
5. Archive filesystem using `tar --files-from` (skips proc/sys/dev/tmp)
6. Bundle everything into a single `tar.gz`
7. SHA-256 checksum

### Restore (`restore.sh`)

Runs on managed node. **Fully idempotent** (safe to run multiple times):

| Step | Action |
|------|--------|
| 1 | Pre-flight: verify archive, check disk space |
| 2 | Stop services gracefully (apache2, oracle-xe-21c) |
| 3 | Extract backup bundle |
| 4 | Restore user/group DB (merge — won't duplicate existing users) |
| 5 | Restore filesystem (tar extract to `/`) |
| 6 | Enforce package versions (install/downgrade if drifted) |
| 7 | Oracle impdp with `TABLE_EXISTS_ACTION=REPLACE` |
| 8 | Restore cron jobs (rsync --ignore-existing) |
| 9 | Fix permissions (www-data, oracle, .ssh/) |
| 10 | Start and verify services |
| 11 | Post-restore health validation |

---

## Self-Healing Mechanism

The controller performs self-healing **before** each restore:

### A. Missing Components
```
Detect: dpkg -l apache2 → not installed
Fix:    apt-get install apache2=<required_version>
```

### B. Version Drift
```
Detect: installed version ≠ versions.json required version
Fix:    apt-get install --allow-downgrades <pkg>=<exact_version>
```

### C. Broken Services
```
Detect: systemctl is-active apache2 → inactive/failed
Fix:    systemctl enable --now apache2
        → if still broken: reapply config + restart
```

### D. Environment Reconstruction
```
Detect: User/directory missing
Fix:    useradd with original UID/GID
        mkdir -p all directories from paths.json
```

### E. Oracle-Specific Healing
```
Detect: oracle-xe-21c not running
Fix:    systemctl restart oracle-xe-21c
        lsnrctl start (via oracle OS user)
```

---

## Oracle XE Backup & Restore

### Backup (`expdp`)
```bash
expdp '/ as sysdba'        \
  FULL=Y                   \
  DUMPFILE=full_XE_<ts>.dmp\
  DIRECTORY=DATA_PUMP_DIR  \
  COMPRESSION=ALL          \
  REUSE_DUMPFILES=YES      \
  PARALLEL=2
```
Also captures:
- SPFILE → PFILE (`init_XE.ora`)
- Control file trace SQL

### Restore (`impdp`)
```bash
impdp '/ as sysdba'              \
  FULL=Y                         \
  DUMPFILE=full_XE_<ts>.dmp      \
  DIRECTORY=DATA_PUMP_DIR        \
  TABLE_EXISTS_ACTION=REPLACE    \
  PARALLEL=2
```

**Idempotency**: `TABLE_EXISTS_ACTION=REPLACE` ensures re-running replaces existing data without errors.

### Credential Security
- Scripts **never** contain passwords
- Uses OS authentication (`/ as sysdba`) when possible
- Falls back to `/etc/bkp_vault/oracle_sys.pass` (root:root, chmod 600)
- `ORACLE_SYS_PASS` env var as last resort (for CI/CD pipelines)

---

## Security

| Control | Implementation |
|---|---|
| **Authentication** | SSH key-based only; `BatchMode=yes` prevents password prompts |
| **Key storage** | `keys/` directory: chmod 700; individual keys: chmod 600 |
| **Oracle creds** | `/etc/bkp_vault/oracle_sys.pass` — root only, never in scripts |
| **Archive encryption** | GPG at-rest encryption (`--encrypt` flag) |
| **No sudo escalation** | Scripts run as SSH user with appropriate permissions |
| **Strict SSH options** | `StrictHostKeyChecking`, `ConnectTimeout`, `ServerAliveInterval` |
| **Log security** | Logs contain no credentials; password fields are masked |

**Recommended additional controls:**
- Run controller from a dedicated bastion host
- Use AWS Secrets Manager or HashiCorp Vault for credentials
- Restrict SSH key permissions to backup service account only
- Enable `StrictHostKeyChecking=yes` after initial setup (add host keys to `known_hosts`)

---

## Scheduling & Automation

`setup.sh` installs `/etc/cron.d/backup-platform`:

```cron
# Daily backup: all servers at 02:30 UTC
30 2 * * *   root   /opt/backup-platform/controller.sh backup --server all

# Weekly discovery: Sundays at 01:00 UTC
0 1 * * 0    root   /opt/backup-platform/controller.sh discover --server all

# Daily status report: 07:00 UTC
0 7 * * *    root   /opt/backup-platform/controller.sh status
```

**Per-server schedules** are stored in `servers.json` (field: `backup_schedule`) — extend `controller.sh` to generate individual cron entries per server.

---

## Logging

| Log File | Contents |
|---|---|
| `logs/controller.log` | All controller activity |
| `logs/backup_<server>_<ts>.log` | Per-backup detailed log |
| `logs/restore_<server>_<ts>.log` | Per-restore detailed log |
| `logs/discover_<server>.log` | Discovery activity |
| `logs/cron_*.log` | Scheduled run output |

Log rotation: configured via `/etc/logrotate.d/backup-platform` — 90 days retention, daily rotation, compressed.

**Log levels:**
- `debug` — SSH commands, remote output, all decisions
- `info`  — Step milestones, success/failure of major operations (default)
- `warn`  — Non-fatal issues that need attention

---

## Troubleshooting

### SSH connection fails
```bash
# Test manually
ssh -i /opt/backup-platform/keys/web-01.pem -o BatchMode=yes ubuntu@10.0.1.10 echo ok

# Common causes:
# - Wrong key path in servers.json
# - Key not authorized on target (~/.ssh/authorized_keys)
# - SSH port not 22 (set ssh_port in servers.json)
```

### Archive integrity fails
```bash
./controller.sh verify --server app-01

# Manual check:
sha256sum --check backups/app-01/latest.tar.gz.sha256
tar -tzf backups/app-01/latest.tar.gz | head -20
```

### Oracle expdp fails
```bash
# Check on managed node:
su - oracle
export ORACLE_SID=XE ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE
lsnrctl status
sqlplus -S / as sysdba <<< "select status from v\$instance;"

# Common issues:
# - Listener not started → lsnrctl start
# - DATA_PUMP_DIR not defined → CREATE DIRECTORY DATA_PUMP_DIR AS '/path';
# - Insufficient space in dump directory
```

### Restore leaves system in partial state
```bash
# Review restore log — it records the exact step where failure occurred
cat logs/restore_<server>_<timestamp>.log

# The restore script does NOT delete staging on failure
# Inspect: /tmp/bkp_agent/restore_extract_*/

# Re-run restore (idempotent — safe to repeat):
./controller.sh restore --server app-01
```

### Version enforcement fails (downgrade)
```bash
# Enable downgrade in apt:
apt-get install -y --allow-downgrades apache2=2.4.52-1ubuntu4.7

# If version not in apt cache, add archive repo:
# deb http://archive.ubuntu.com/ubuntu/ focal main
```

---

## Design Decisions

| Decision | Rationale |
|---|---|
| **No agent daemon** | Reduces attack surface; SSH is ubiquitous and auditable |
| **scripts pushed at runtime** | Always runs latest controller-side script version; no version drift on nodes |
| **paths.json driven** | Decouples discovery from backup logic; adaptable to any server layout |
| **expdp full export** | Safest Oracle backup method; no corruption risk vs physical copy |
| **TABLE_EXISTS_ACTION=REPLACE** | Enables idempotent DB restore without dropping and re-creating |
| **tar --ignore-failed-read** | Handles files changing during backup (logs, tmp) without aborting |
| **Staging dir per PID** | Prevents conflicts during parallel operations |
| **Symlink to latest** | Simplifies "restore from latest" without scripting date logic |
| **SHA-256 checksums** | Detects corruption before attempting restore |
| **Retry wrapper** | Handles transient SSH/network failures gracefully |
