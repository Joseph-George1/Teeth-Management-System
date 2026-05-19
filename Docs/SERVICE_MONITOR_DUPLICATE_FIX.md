# Service Monitor Duplicate Execution Fix

## Problem Identified

Your service monitor is experiencing duplicate executions, causing:
- ✗ Duplicate log entries in `service_monitor.log`
- ✗ Duplicate Discord notifications being sent  
- ✗ Inefficient resource usage with redundant health checks

**Root Cause**: Multiple identical cron entries running `service_monitor.sh` simultaneously.

From the logs:
```
2026-05-16T14:10:01Z | INFO | ========== Service Monitor Started ==========
2026-05-16T14:10:02Z | INFO | ========== Service Monitor Started ==========  ← Duplicate
```

## Solution Implemented

### 1. **Concurrency Lock Added to `service_monitor.sh`**

Added a file-based locking mechanism that:
- Creates a lock file when the monitor starts
- Prevents concurrent executions (second instance exits gracefully)
- Auto-releases lock on script completion
- Cleans up stale locks after 5 minutes

**Changes made**:
```bash
# Added lock functions:
acquire_lock()    # Acquires execution lock
release_lock()    # Releases lock on exit

# Updated main() to use lock:
trap release_lock EXIT INT TERM
```

### 2. **Crontab Cleanup Script Created**

New tool: `cleanup_crontab.sh` helps identify and remove duplicate cron entries.

## Steps to Fix on EC2 Instance

### Step 1: Update `service_monitor.sh` (DONE ✓)
The lock mechanism has been added. No action needed.

### Step 2: Run Crontab Cleanup  
```bash
cd ~/Teeth-Management-System
bash cleanup_crontab.sh
```

This script will:
1. Count existing cron entries for service_monitor
2. Show you all duplicate entries
3. Help you remove duplicates
4. Configure a single entry with your preferred frequency

### Step 3: Verify the Fix
```bash
# Check crontab entries (should see only ONE line)
crontab -l | grep service_monitor

# Monitor the logs (should see single execution cycle)
tail -f ~/Teeth-Management-System/logs/service_monitor.log

# Check service status
astart -l
```

## Expected Results After Fix

**Logs** - Should see single execution:
```
2026-05-16T14:15:01Z | INFO | ========== Service Monitor Started ==========
2026-05-16T14:15:02Z | WARN | Service notification_service: Health check failed (HTTP 503)
2026-05-16T14:15:02Z | INFO | Discord notification sent for notification_service
...
2026-05-16T14:15:08Z | INFO | ========== Service Monitor Completed ==========
```

**Discord** - Single notification per event (no duplicates)

**Resource Usage** - Reduced CPU and network overhead

## How the Lock Works

1. When script starts, tries to acquire lock file: `.monitor.lock`
2. If lock exists and is recent (< 5 min old), exits immediately
3. If lock is stale (> 5 min old), removes it and continues
4. Creates new lock with current PID
5. On exit (normal or error), removes lock file

This prevents the scenario where:
- Cron job #1 starts at 14:10:01
- Cron job #2 starts at 14:10:02 (before job #1 finishes)
- Both run simultaneously → duplicate logs & notifications

## Troubleshooting

### If duplicate logs still appear:
```bash
# Check if old cron entries still exist
crontab -l

# If multiple entries, clean them up
bash cleanup_crontab.sh

# Check for stale lock file
ls -la ~/Teeth-Management-System/logs/.monitor.lock

# Manually remove if stuck
rm -f ~/Teeth-Management-System/logs/.monitor.lock
```

### If Discord notifications are still duplicated:
1. Wait for next cron execution (after cleanup)
2. The lock mechanism takes effect on the next run
3. May need to restart cron: `sudo service cron restart`

### To disable/modify cron schedule:
```bash
# Remove all monitor entries
(crontab -l | grep -v service_monitor) | crontab -

# Or use the cleanup script to reconfigure
bash cleanup_crontab.sh
```

## Files Modified

- ✓ `service_monitor.sh` - Added lock mechanism
- ✓ `cleanup_crontab.sh` - New cleanup utility

## Next Steps

1. **SSH into EC2 instance** and run:
   ```bash
   cd ~/Teeth-Management-System
   bash cleanup_crontab.sh
   ```

2. **Verify** by checking logs after next monitor cycle:
   ```bash
   tail -f logs/service_monitor.log
   ```

3. **Confirm** Discord notifications are no longer duplicated

---

**Questions or issues?** Check the logs and refer to the troubleshooting section above.
