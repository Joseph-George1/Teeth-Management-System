#!/usr/bin/env bash

################################################################################
# Service Monitor & Auto-Recovery Script
# Purpose: Monitor system services, auto-restart if down, notify via Discord
# 
# Usage (Crontab Examples):
#   # Check every 5 minutes
#   */5 * * * * /home/ubuntu/Teeth-Management-System/service_monitor.sh
#   
#   # Check every hour
#   0 * * * * /home/ubuntu/Teeth-Management-System/service_monitor.sh
#   
#   # Check every day at 2 AM
#   0 2 * * * /home/ubuntu/Teeth-Management-System/service_monitor.sh
#
# Configuration:
#   Set DISCORD_WEBHOOK_URL environment variable or edit below
#   Set ASTART_PATH if using non-standard location
#
# Dependencies:
#   - curl (for health checks and Discord notifications)
#   - systemctl (for system services)
#   - bash
################################################################################

set -o pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
ASTART_SCRIPT="$PROJECT_DIR/astart"
LOG_FILE="$PROJECT_DIR/logs/service_monitor.log"
LOG_DIR="$PROJECT_DIR/logs"

#===============================================================================
# Notification Configuration
#===============================================================================

# Discord webhook URL
# Get from: Discord Server Settings → Integrations → Webhooks → Copy Webhook URL
# Example: https://discord.com/api/webhooks/1234567890/abcdefghijklmnopqrstuvwxyz
DISCORD_WEBHOOK_URL="YOUR_DISCORD_WEBHOOK_URL_HERE"

# WhatsApp configuration (WAHA API)
WAHA_API_URL="http://127.0.0.1:3000"
WAHA_API_KEY="YOUR_WAHA_API_KEY_HERE"  # Leave empty "" if no API key required
WAHA_SESSION="default"

# Phone numbers to receive WhatsApp alerts (without + prefix)
# Add more numbers as needed: ("2012345678" "2009876543" "2001234567")
WHATSAPP_PHONES=("201226191421" "201097727531")

# Timeout for health checks (seconds)
HEALTH_CHECK_TIMEOUT=5

# Color codes for logging
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

#===============================================================================
# Service Definition
# Format: SERVICE_NAME|port|health_endpoint|restart_method|restart_command
#===============================================================================
# restart_method: 'systemctl', 'astart', or 'manual'
# restart_command: command to run for restart
#
declare -A SERVICES=(
    # HTTP-based services (checked via port + endpoint)
    [backend]="8080||astart|bash $ASTART_SCRIPT -b"
    [proxy_server]="5173||astart|bash $ASTART_SCRIPT -p"
    [otp_service]="8000|/health|astart|bash $ASTART_SCRIPT -o"
    [password_reset]="7000||astart|bash $ASTART_SCRIPT -f"
    [notification_service]="9000|/health|astart|bash $ASTART_SCRIPT -n"
    
    # Systemctl services (special Discord bot services)
    [flask-api.service]="5010||systemctl|sudo systemctl start flask-api.service"
    [bot.service]="||systemctl|sudo systemctl start bot.service"
)

#===============================================================================
# Utility Functions
#===============================================================================

init_logging() {
    mkdir -p "$LOG_DIR"
    touch "$LOG_FILE"
}

log_message() {
    local level="$1"
    local message="$2"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "$timestamp | $level | $message" >> "$LOG_FILE"
    [ "$VERBOSE" = "1" ] && echo -e "${BLUE}[$level]${NC} $message" >&2
}

error_log() { log_message "ERROR" "$1"; }
info_log() { log_message "INFO" "$1"; }
warn_log() { log_message "WARN" "$1"; }

#===============================================================================
# Health Check Functions
#===============================================================================

check_port() {
    local port=$1
    if command -v lsof >/dev/null 2>&1; then
        lsof -i:"$port" >/dev/null 2>&1
        return $?
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tuln 2>/dev/null | grep -q ":$port " && return 0 || return 1
    else
        # Fallback: try curl
        timeout 2 bash -c "echo >/dev/tcp/127.0.0.1/$port" 2>/dev/null && return 0 || return 1
    fi
}

check_service_health() {
    local service_name="$1"
    local port="$2"
    local endpoint="$3"
    
    # If no port, service check failed
    if [ -z "$port" ]; then
        return 1
    fi
    
    # Check if port is listening
    if ! check_port "$port"; then
        info_log "Service $service_name: Port $port is not listening"
        return 1
    fi
    
    # If endpoint specified, do HTTP health check
    if [ -n "$endpoint" ]; then
        local url="http://127.0.0.1:$port$endpoint"
        local response
        response=$(curl -s -w "\n%{http_code}" -m "$HEALTH_CHECK_TIMEOUT" "$url" 2>/dev/null)
        local http_code=$(echo "$response" | tail -n1)
        
        if [ "$http_code" = "200" ]; then
            info_log "Service $service_name: Health check passed (HTTP 200)"
            return 0
        else
            warn_log "Service $service_name: Health check failed (HTTP $http_code)"
            return 1
        fi
    fi
    
    # Port is listening and no endpoint check needed
    info_log "Service $service_name: Port $port is listening"
    return 0
}

#===============================================================================
# Discord Notification Functions
#===============================================================================

send_discord_notification() {
    local title="$1"
    local description="$2"
    local color="$3"  # Decimal color code: 16711680 (red), 65280 (green)
    local service_name="$4"
    
    if [ -z "$DISCORD_WEBHOOK_URL" ]; then
        warn_log "Discord webhook not configured. Skipping notification."
        return 1
    fi
    
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local hostname=$(hostname)
    
    local payload=$(cat <<EOF
{
    "username": "Service Monitor Bot",
    "avatar_url": "https://thoutha.page/%D8%AB%D9%88%D8%AB%D8%A9.png",
    "embeds": [
        {
            "title": "$title",
            "description": "$description",
            "color": $color,
            "fields": [
                {
                    "name": "Service",
                    "value": "$service_name",
                    "inline": true
                },
                {
                    "name": "Hostname",
                    "value": "$hostname",
                    "inline": true
                },
                {
                    "name": "Timestamp",
                    "value": "$timestamp",
                    "inline": false
                }
            ],
            "footer": {
                "text": "Service Monitoring System"
            }
        }
    ]
}
EOF
)
    
    local response
    response=$(curl -s -X POST "$DISCORD_WEBHOOK_URL" \
        -H 'Content-Type: application/json' \
        -d "$payload" 2>&1)
    
    if echo "$response" | grep -q "error"; then
        error_log "Failed to send Discord notification: $response"
        return 1
    fi
    
    info_log "Discord notification sent for $service_name"
    return 0
}

send_whatsapp_notification() {
    local title="$1"
    local description="$2"
    local service_name="$3"
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local hostname=$(hostname)
    
    # Construct WhatsApp message
    local message="*🔔 Service Monitor Alert*

*Title:* $title
*Service:* $service_name
*Host:* $hostname
*Time:* $timestamp

$description"
    
    # Send to each phone number
    for phone in "${WHATSAPP_PHONES[@]}"; do
        # Format: number@c.us (WhatsApp format)
        local chat_id="${phone}@c.us"
        
        # Prepare payload for WAHA API
        local payload=$(cat <<EOF
{
    "chatId": "$chat_id",
    "text": "$message",
    "session": "$WAHA_SESSION"
}
EOF
)
        
        local waha_endpoint="$WAHA_API_URL/api/sendText"
        
        # Send request
        local response
        response=$(curl -s -X POST "$waha_endpoint" \
            -H 'Content-Type: application/json' \
            -d "$payload" 2>&1)
        
        if echo "$response" | grep -q 'error'; then
            warn_log "Failed to send WhatsApp to +$phone: $response"
        else
            info_log "WhatsApp notification sent to +$phone for $service_name"
        fi
    done
    
    return 0
}

send_service_down_notification() {
    local service_name="$1"
    send_discord_notification \
        "🔴 Service Down" \
        "Service **$service_name** is **DOWN** and recovery attempts failed." \
        16711680 \
        "$service_name"
    send_whatsapp_notification \
        "🔴 Service Down" \
        "Service $service_name is DOWN and recovery attempts failed." \
        "$service_name"
}

send_service_recovering_notification() {
    local service_name="$1"
    send_discord_notification \
        "🟡 Service Recovering" \
        "Service **$service_name** was down. Attempting automatic recovery..." \
        16776960 \
        "$service_name"
    send_whatsapp_notification \
        "🟡 Service Recovering" \
        "Service $service_name was down. Attempting automatic recovery..." \
        "$service_name"
}

send_service_recovered_notification() {
    local service_name="$1"
    send_discord_notification \
        "🟢 Service Recovered" \
        "Service **$service_name** has been **RECOVERED**." \
        65280 \
        "$service_name"
    send_whatsapp_notification \
        "🟢 Service Recovered" \
        "Service $service_name has been RECOVERED." \
        "$service_name"
}

#===============================================================================
# Recovery Functions
#===============================================================================

restart_service() {
    local service_name="$1"
    local restart_method="$2"
    local restart_command="$3"
    
    info_log "Attempting to restart $service_name using $restart_method..."
    
    case "$restart_method" in
        systemctl)
            if sudo systemctl is-active --quiet "$service_name" 2>/dev/null; then
                info_log "$service_name is already running via systemctl"
                return 0
            fi
            
            info_log "Restarting $service_name via systemctl..."
            if eval "$restart_command" >/dev/null 2>&1; then
                sleep 2
                if sudo systemctl is-active --quiet "$service_name" 2>/dev/null; then
                    info_log "Successfully restarted $service_name via systemctl"
                    return 0
                else
                    error_log "Failed to restart $service_name via systemctl"
                    return 1
                fi
            else
                error_log "systemctl restart command failed for $service_name"
                return 1
            fi
            ;;
            
        astart)
            if [ ! -f "$ASTART_SCRIPT" ]; then
                error_log "astart script not found at $ASTART_SCRIPT"
                return 1
            fi
            
            info_log "Restarting $service_name via astart..."
            if eval "$restart_command" >/dev/null 2>&1; then
                sleep 3
                return 0
            else
                error_log "Failed to restart $service_name via astart"
                return 1
            fi
            ;;
            
        *)
            warn_log "Unknown restart method: $restart_method"
            return 1
            ;;
    esac
}

#===============================================================================
# Locking Mechanism (Prevents Concurrent Executions)
#===============================================================================

LOCK_FILE="$LOG_DIR/.monitor.lock"
LOCK_TIMEOUT=300  # 5 minutes - if lock is older, consider it stale

acquire_lock() {
    # Check if lock exists and is fresh
    if [ -f "$LOCK_FILE" ]; then
        local lock_age=$(($(date +%s) - $(stat -c %Y "$LOCK_FILE" 2>/dev/null || echo 0)))
        if [ $lock_age -lt $LOCK_TIMEOUT ]; then
            # Lock exists and is fresh - another instance is running
            return 1
        else
            # Lock is stale, remove it
            rm -f "$LOCK_FILE"
        fi
    fi
    
    # Create lock file
    mkdir -p "$LOG_DIR"
    echo $$ > "$LOCK_FILE"
    return 0
}

release_lock() {
    rm -f "$LOCK_FILE"
}

#===============================================================================
# Main Monitoring Loop
#===============================================================================

monitor_services() {
    init_logging
    info_log "========== Service Monitor Started =========="
    
    local failed_services=()
    local recovered_services=()
    
    # Check each service
    for service_name in "${!SERVICES[@]}"; do
        local service_config="${SERVICES[$service_name]}"
        local port=$(echo "$service_config" | cut -d'|' -f1)
        local endpoint=$(echo "$service_config" | cut -d'|' -f2)
        local restart_method=$(echo "$service_config" | cut -d'|' -f3)
        local restart_command=$(echo "$service_config" | cut -d'|' -f4)
        
        # Special handling for systemctl services (no port check)
        if [ "$restart_method" = "systemctl" ]; then
            if sudo systemctl is-active --quiet "$service_name" 2>/dev/null; then
                info_log "Service $service_name is running (systemctl)"
            else
                warn_log "Service $service_name is DOWN (systemctl)"
                failed_services+=("$service_name|$restart_method|$restart_command")
            fi
            continue
        fi
        
        # Check health for HTTP-based services
        if check_service_health "$service_name" "$port" "$endpoint"; then
            # Service is healthy
            info_log "✓ $service_name is healthy"
        else
            # Service is down, try to recover
            warn_log "✗ $service_name is DOWN - attempting recovery"
            failed_services+=("$service_name|$restart_method|$restart_command")
            
            # Attempt restart (no notification yet - only on final outcome)
            if restart_service "$service_name" "$restart_method" "$restart_command"; then
                # Check again after restart
                sleep 2
                if check_service_health "$service_name" "$port" "$endpoint"; then
                    info_log "✓ $service_name recovered successfully"
                    recovered_services+=("$service_name")
                    # Send notification ONLY on successful recovery
                    send_service_recovered_notification "$service_name"
                else
                    error_log "✗ $service_name still down after restart attempt"
                    # Send notification ONLY on failed recovery
                    send_service_down_notification "$service_name"
                fi
            else
                error_log "✗ Failed to restart $service_name"
                # Send notification ONLY on failed restart
                send_service_down_notification "$service_name"
            fi
        fi
    done
    
    info_log "========== Service Monitor Completed =========="
    info_log "Summary: Checked ${#SERVICES[@]} services, Failed: ${#failed_services[@]}, Recovered: ${#recovered_services[@]}"
}

#===============================================================================
# Script Entry Point
#===============================================================================

main() {
    # Allow override via environment
    VERBOSE="${VERBOSE:-0}"
    
    # Acquire lock to prevent concurrent executions
    if ! acquire_lock; then
        warn_log "Another monitor instance is already running. Exiting."
        exit 0
    fi
    
    # Ensure cleanup on exit
    trap release_lock EXIT INT TERM
    
    # Ensure we can run astart if needed
    if [ ! -x "$ASTART_SCRIPT" ]; then
        chmod +x "$ASTART_SCRIPT" 2>/dev/null || true
    fi
    
    monitor_services
}

# Run main function
main "$@"
exit 0
