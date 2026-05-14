# Service Monitor & Auto-Recovery Crontab Script

## Overview

This is a bash-based monitoring script that:
1. **Monitors** all system services for health/availability
2. **Auto-restarts** failed services automatically
3. **Notifies** system administrators via Discord when services fail or recover

## Services Monitored

The script monitors these 7 services configured in `service_monitor.sh`:

| Service Name | Port | Health Endpoint | Restart Method |
|---|---|---|---|
| backend | 8080 | - | astart |
| proxy_server | 5173 | - | astart |
| otp_service | 8000 | /health | astart |
| password_reset | 7000 | - | astart |
| notification_service | 9000 | /api/notify/health | astart |
| flask-api.service | 5010 | - | systemctl |
| bot.service | - | - | systemctl |

## Installation & Setup

### 1. Make Script Executable

```bash
chmod +x ~/Teeth-Management-System/service_monitor.sh
```

### 2. Configure Discord Webhook URL

You have two options:

**Option A: Set Environment Variable (Recommended)**
```bash
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"

# Add to ~/.bashrc or ~/.bash_profile to persist:
echo 'export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"' >> ~/.bashrc
source ~/.bashrc
```

**Option B: Edit Script Directly**
```bash
# Edit service_monitor.sh and change:
DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/YOUR_WEBHOOK_ID/YOUR_WEBHOOK_TOKEN"
```

### 3. Create Discord Webhook

1. Go to your Discord Server Settings → Webhooks
2. Click "Create Webhook"
3. Name it "Service Monitor Bot"
4. Select the channel where notifications should appear
5. Copy the Webhook URL
6. Click "Save"

## Crontab Configuration

### View Current Crontab
```bash
crontab -l
```

### Edit Crontab
```bash
crontab -e
```

### Example Crontab Entries

**Check Every 5 Minutes**
```bash
*/5 * * * * ~/Teeth-Management-System/service_monitor.sh
```

**Check Every 15 Minutes**
```bash
*/15 * * * * ~/Teeth-Management-System/service_monitor.sh
```

**Check Every Hour**
```bash
0 * * * * ~/Teeth-Management-System/service_monitor.sh
```

**Check Every 6 Hours**
```bash
0 */6 * * * ~/Teeth-Management-System/service_monitor.sh
```

**Check Daily at 2 AM**
```bash
0 2 * * * ~/Teeth-Management-System/service_monitor.sh
```

**Check Multiple Times Daily (2 AM, 8 AM, 2 PM, 8 PM)**
```bash
0 2,8,14,20 * * * ~/Teeth-Management-System/service_monitor.sh
```

## Crontab Format Reference

```
# Format:
# ┌─────────── minute (0 - 59)
# │ ┌─────────── hour (0 - 23)
# │ │ ┌─────────── day of month (1 - 31)
# │ │ │ ┌─────────── month (1 - 12)
# │ │ │ │ ┌─────────── day of week (0 - 7) (0 and 7 are Sunday)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * command_to_run

# Special symbols:
# *     = every value
# */n   = every n values (e.g., */5 = every 5 minutes)
# n-m   = range from n to m
# n,m,k = specific values n, m, and k
```

## Testing the Script

### Run Manually with Verbose Output
```bash
VERBOSE=1 ~/Teeth-Management-System/service_monitor.sh
```

### View Logs
```bash
# Real-time monitoring of logs
tail -f ~/Teeth-Management-System/logs/service_monitor.log

# View recent entries
tail -50 ~/Teeth-Management-System/logs/service_monitor.log

# Search for specific service
grep "backend" ~/Teeth-Management-System/logs/service_monitor.log
```

### Check Crontab Log (Ubuntu/Ubuntu)
```bash
# View system cron logs
sudo tail -f /var/log/syslog | grep CRON

# Or use journalctl
sudo journalctl -u cron -f
```

## Log File Location

Logs are stored at:
```
~/Teeth-Management-System/logs/service_monitor.log
```

## Customization

### Adding a New Service

Edit `service_monitor.sh` and add to the `SERVICES` array:

```bash
SERVICES=(
    [new_service_name]="port|/health/endpoint|restart_method|restart_command"
    # Example:
    [my_api]="5050|/health|astart|bash $ASTART_SCRIPT -custom-flag"
)
```

### Changing Health Check Timeout

```bash
# Default is 5 seconds, change this line:
HEALTH_CHECK_TIMEOUT=10
```

### Adjusting Restart Delay

After restart, the script waits 2-3 seconds before re-checking health. To change:

Find the `sleep` lines and adjust:
```bash
sleep 3  # Increase or decrease as needed
```

## Discord Notification Details

### When Notifications Are Sent

1. **🟡 Service Recovering**: Service is down, attempting automatic restart
2. **🟢 Service Recovered**: Service was successfully recovered
3. **🔴 Service Down**: Service restart failed, manual intervention needed

### Notification Information

Each notification includes:
- Service name
- Hostname where it's running
- Timestamp (UTC)
- Status indicator

## Troubleshooting

### Script Not Running

Check if crontab is enabled:
```bash
sudo systemctl status cron
# or
sudo systemctl status crond
```

Enable if needed:
```bash
sudo systemctl enable cron
sudo systemctl start cron
```

### Discord Notifications Not Sending

1. Verify webhook URL:
```bash
curl -X POST "YOUR_WEBHOOK_URL" \
  -H 'Content-Type: application/json' \
  -d '{"content":"Test"}'
```

2. Check logs for errors:
```bash
grep "Discord\|webhook\|error" ~/Teeth-Management-System/logs/service_monitor.log
```

### Services Not Restarting

1. Check astart script exists and is executable:
```bash
ls -la ~/Teeth-Management-System/astart
```

2. Run script manually to debug:
```bash
VERBOSE=1 bash ~/Teeth-Management-System/service_monitor.sh
```

3. Check service start logs:
```bash
tail -f ~/Teeth-Management-System/logs/process_logs/backend*.log
```

## Advanced: Integration with Monitoring Tools

### Send to Slack Instead of Discord

Replace Discord notification calls with Slack webhook:

```bash
# Change in send_discord_notification function:
curl -s -X POST "$SLACK_WEBHOOK_URL" \
    -H 'Content-Type: application/json' \
    -d "{\"text\": \"$title: $description\"}"
```

### Send Email Notifications

Add email function:

```bash
send_email_notification() {
    echo "$1" | mail -s "Service Monitor Alert" admin@example.com
}
```

### Log to Remote Server

Append to remote logging service:

```bash
echo "$timestamp | $message" | logger -h remote.syslog.server
```

## Performance Considerations

- Each health check makes up to 3 small HTTP requests
- Script typically completes in 10-30 seconds depending on services
- Suggested minimum interval: **5 minutes**
- For production with critical services: **1-2 minutes**

## Security Notes

1. **Discord Webhook URL**: Keep this secret, treat like a password
2. **Crontab Permissions**: Only your user can see/modify your crontab
3. **Log Files**: Contain service details, ensure log directory has restricted permissions
4. **systemctl Services**: Script uses `sudo` for systemctl commands, ensure sudoers entry allows password-less execution for needed commands

### Allow Password-less sudo for systemctl

Add to sudoers (run `sudo visudo`):
```bash
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl start flask-api.service
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl start bot.service
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl is-active flask-api.service
ubuntu ALL=(ALL) NOPASSWD: /bin/systemctl is-active bot.service
```

## Example Complete Setup

```bash
# 1. Make executable
chmod +x ~/Teeth-Management-System/service_monitor.sh

# 2. Set Discord webhook (replace with your actual webhook)
export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/123456/abcdef"
echo 'export DISCORD_WEBHOOK_URL="https://discord.com/api/webhooks/123456/abcdef"' >> ~/.bashrc

# 3. Add to crontab (check every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * ~/Teeth-Management-System/service_monitor.sh") | crontab -

# 4. Verify
crontab -l  # Should show the new entry

# 5. Test
VERBOSE=1 ~/Teeth-Management-System/service_monitor.sh
```

## Support & Debugging

For detailed debugging:
```bash
# Enable verbose mode and redirect to file
VERBOSE=1 ~/Teeth-Management-System/service_monitor.sh 2>&1 | tee -a ~/Teeth-Management-System/logs/debug.log
```

## References

- [Cron Job Format](https://crontab.guru/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)
- [Discord Webhooks](https://discord.com/developers/docs/resources/webhook)
- [Linux systemctl Manual](https://linux.die.net/man/1/systemctl)
