# Service Monitor - Quick Reference Guide

## Quick Start (One Command)

```bash
# Run interactive setup
bash ~/Teeth-Management-System/setup_service_monitor.sh
```

## Manual Quick Setup

```bash
# 1. Make executable
chmod +x ~/Teeth-Management-System/service_monitor.sh

# 2. Set Discord webhook
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_ID/YOUR_TOKEN"
echo 'export DISCORD_WEBHOOK_URL="..."' >> ~/.bashrc

# 3. Add to crontab (every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/Teeth-Management-System/service_monitor.sh") | crontab -

# 4. Verify
crontab -l
```

## Common Commands

### View Service Status

```bash
# Show all services in PID files
ls -la ~/Teeth-Management-System/logs/pids/

# Show running services
ps aux | grep python3
ps aux | grep java
```

### View Logs

```bash
# Real-time log monitoring
tail -f ~/Teeth-Management-System/logs/service_monitor.log

# Last 20 entries
tail -20 ~/Teeth-Management-System/logs/service_monitor.log

# Search for specific service
grep "backend" ~/Teeth-Management-System/logs/service_monitor.log

# Count errors
grep "ERROR" ~/Teeth-Management-System/logs/service_monitor.log | wc -l

# Show errors only
grep "ERROR\|WARN" ~/Teeth-Management-System/logs/service_monitor.log
```

### Test Script Manually

```bash
# Run with verbose output
VERBOSE=1 ~/Teeth-Management-System/service_monitor.sh

# Run and show output
bash -x ~/Teeth-Management-System/service_monitor.sh

# Test specific health check
curl http://127.0.0.1:5010/health
curl http://127.0.0.1:8000/health
curl http://127.0.0.1:9000/api/notify/health
```

### Manage Crontab

```bash
# View current crontab
crontab -l

# Edit crontab
crontab -e

# Remove crontab
crontab -r

# Install from file
crontab /path/to/crontab.file

# List all crontabs (as root)
sudo for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l 2>/dev/null; done
```

### Manage Services Manually

```bash
# Start individual service
bash ~/Teeth-Management-System/astart -b    # Backend
bash ~/Teeth-Management-System/astart -p    # Proxy
bash ~/Teeth-Management-System/astart -o    # OTP
bash ~/Teeth-Management-System/astart -f    # Password Reset
bash ~/Teeth-Management-System/astart -n    # Notification

# Stop all services
bash ~/Teeth-Management-System/astart -s

# View status
bash ~/Teeth-Management-System/astart -l

# View logs
bash ~/Teeth-Management-System/astart -L backend
bash ~/Teeth-Management-System/astart -F backend follow  # Follow mode
```

### Systemctl Services

```bash
# Check status
sudo systemctl status flask-api.service
sudo systemctl status bot.service

# Start service
sudo systemctl start flask-api.service
sudo systemctl start bot.service

# Stop service
sudo systemctl stop flask-api.service
sudo systemctl stop bot.service

# Restart service
sudo systemctl restart flask-api.service
sudo systemctl restart bot.service

# Enable on boot
sudo systemctl enable flask-api.service
sudo systemctl enable bot.service

# View logs
sudo journalctl -u flask-api.service -f
sudo journalctl -u bot.service -f
```

## Crontab Scheduling Patterns

```
# Every minute
* * * * * command

# Every 5 minutes
*/5 * * * * command

# Every hour at :00
0 * * * * command

# Every day at 2 AM
0 2 * * * command

# Every Monday at 9 AM
0 9 * * 1 command

# Every 1st of month at midnight
0 0 1 * * command

# Multiple times (2 AM, 8 AM, 2 PM)
0 2,8,14 * * * command

# Every 6 hours
0 */6 * * * command

# Weekdays only (Monday-Friday)
0 14 * * 1-5 command

# Business hours (9 AM - 5 PM, every hour)
0 9-17 * * 1-5 command
```

## Troubleshooting

### Script Not Running via Crontab

```bash
# 1. Check if cron is running
sudo systemctl status cron

# 2. Start cron if needed
sudo systemctl start cron
sudo systemctl enable cron

# 3. Check cron logs
sudo grep CRON /var/log/syslog | tail -20

# 4. Or use journalctl
sudo journalctl -u cron -n 20

# 5. Check if script path is absolute
crontab -l  # Path must be absolute, not relative

# 6. Verify script is executable
ls -la ~/Teeth-Management-System/service_monitor.sh
# Should show: -rwxr-xr-x
```

### Cron Not Finding Commands

```bash
# Add full path to crontab
*/5 * * * * /usr/bin/curl ...
*/5 * * * * /bin/bash ~/path/to/script.sh

# Or source .bashrc
*/5 * * * * . ~/.bashrc; ~/Teeth-Management-System/service_monitor.sh

# List available commands
which curl
which bash
which systemctl
```

### Webhook Not Sending

```bash
# Test webhook manually
WEBHOOK_URL="your_webhook_url"

curl -X POST "$WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d '{
    "username": "Test Bot",
    "content": "Test message"
  }'

# Check response (should be empty with HTTP 204)
```

### Permissions Issues with systemctl

```bash
# Allow specific commands via sudo without password (run 'sudo visudo')
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl start flask-api.service
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl is-active flask-api.service

# Or allow all systemctl for user
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl

# Test
sudo -n systemctl start flask-api.service  # Should work without password prompt
```

## Monitoring Status

### Quick Health Check

```bash
#!/bin/bash
SERVICES=("backend:8080" "otp_service:8000" "notification:9000")

for svc in "${SERVICES[@]}"; do
    IFS=: read name port <<< "$svc"
    if timeout 2 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null; then
        echo "✓ $name is responding"
    else
        echo "✗ $name is DOWN"
    fi
done
```

### Check Cron Execution History

```bash
# Linux/Ubuntu
sudo grep "service_monitor" /var/log/syslog
sudo journalctl | grep "service_monitor"

# Check if cron ran
sudo grep CRON /var/log/syslog | tail -5

# Check for errors
sudo journalctl SYSLOG_IDENTIFIER=CRON -n 30
```

## File Locations

```
Script:          ~/Teeth-Management-System/service_monitor.sh
Setup Script:    ~/Teeth-Management-System/setup_service_monitor.sh
Documentation:   ~/Teeth-Management-System/SERVICE_MONITOR_README.md
Quick Ref:       ~/Teeth-Management-System/SERVICE_MONITOR_QUICK_REF.md

Service Logs:    ~/Teeth-Management-System/logs/service_monitor.log
Service Logs:    ~/Teeth-Management-System/logs/process_logs/
PID Files:       ~/Teeth-Management-System/logs/pids/
Activity Log:    ~/Teeth-Management-System/logs/astart_activity.log
```

## Crontab Editing Tips

```bash
# Edit crontab with specific editor
EDITOR=nano crontab -e
EDITOR=vim crontab -e

# Backup crontab
crontab -l > ~/crontab_backup.txt

# Restore from backup
crontab ~/crontab_backup.txt

# Install specific crontab file
crontab < /tmp/crontab_file

# View other user's crontab (as root)
sudo crontab -u username -l

# Remove all entries for a user (dangerous!)
sudo crontab -u username -r
```

## Environment Variables in Crontab

```bash
# Set environment at top of crontab
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/...
VERBOSE=1

# Or source before command
*/5 * * * * . ~/.bashrc; ~/script.sh

# Or use absolute paths and full commands
*/5 * * * * /usr/bin/curl ...
*/5 * * * * /bin/bash -c "source ~/.bashrc && ~/Teeth-Management-System/service_monitor.sh"
```

## Alternative: systemd Timer (Modern Linux)

Instead of crontab, you can use systemd timer:

```bash
# Create service file: ~/.config/systemd/user/service-monitor.service
[Unit]
Description=Service Monitor
After=network.target

[Service]
Type=simple
ExecStart=/home/ubuntu/Teeth-Management-System/service_monitor.sh
Environment="DISCORD_WEBHOOK_URL=..."

# Create timer file: ~/.config/systemd/user/service-monitor.timer
[Unit]
Description=Run Service Monitor Every 5 Minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target

# Enable and start
systemctl --user daemon-reload
systemctl --user enable service-monitor.timer
systemctl --user start service-monitor.timer
systemctl --user status service-monitor.timer
```

## For More Help

- Read: `SERVICE_MONITOR_README.md` - Comprehensive documentation
- Run: `bash setup_service_monitor.sh` - Interactive setup wizard
- Test: `VERBOSE=1 ~/Teeth-Management-System/service_monitor.sh` - Run with debug output
- Logs: `tail -f ~/Teeth-Management-System/logs/service_monitor.log` - Watch in real-time
