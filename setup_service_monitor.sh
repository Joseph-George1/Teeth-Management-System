#!/usr/bin/env bash

################################################################################
# Service Monitor Setup Script
# Quickly configure and enable crontab-based service monitoring
################################################################################

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR_SCRIPT="$PROJECT_DIR/service_monitor.sh"
MONITOR_README="$PROJECT_DIR/SERVICE_MONITOR_README.md"

# Colors
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
RED='\033[0;31m'
NC='\033[0m'

#===============================================================================
# Welcome
#===============================================================================

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}  Service Monitor Setup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

#===============================================================================
# Check Prerequisites
#===============================================================================

echo -e "${BLUE}Step 1: Checking Prerequisites...${NC}"

# Check if scripts exist
if [ ! -f "$MONITOR_SCRIPT" ]; then
    echo -e "${RED}✗ service_monitor.sh not found at $MONITOR_SCRIPT${NC}"
    exit 1
fi
echo -e "${GREEN}✓ service_monitor.sh found${NC}"

# Check if README exists
if [ ! -f "$MONITOR_README" ]; then
    echo -e "${RED}✗ SERVICE_MONITOR_README.md not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ SERVICE_MONITOR_README.md found${NC}"

# Check required commands
for cmd in curl systemctl crontab; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${RED}✗ Required command not found: $cmd${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All required commands found${NC}"

echo ""

#===============================================================================
# Make Scripts Executable
#===============================================================================

echo -e "${BLUE}Step 2: Making Scripts Executable...${NC}"
chmod +x "$MONITOR_SCRIPT"
echo -e "${GREEN}✓ service_monitor.sh is executable${NC}"

echo ""

#===============================================================================
# Discord Webhook Configuration
#===============================================================================

echo -e "${BLUE}Step 3: Discord Webhook Configuration${NC}"
echo -e "${YELLOW}This script can send notifications to Discord when services fail.${NC}"
echo ""

read -p "Do you want to configure Discord notifications? (y/n): " -r SETUP_DISCORD

if [[ $SETUP_DISCORD =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}To create a Discord webhook:${NC}"
    echo "1. Go to your Discord Server Settings → Integrations → Webhooks"
    echo "2. Click 'Create Webhook'"
    echo "3. Name it 'Service Monitor Bot'"
    echo "4. Select the channel for notifications"
    echo "5. Click 'Copy Webhook URL'"
    echo ""
    
    read -p "Enter your Discord Webhook URL (or press Enter to skip): " WEBHOOK_URL
    
    if [ -n "$WEBHOOK_URL" ]; then
        # Test webhook
        echo -e "${YELLOW}Testing Discord webhook...${NC}"
        
        test_payload='{
            "username": "Service Monitor Bot",
            "content": "✅ Discord webhook is working!"
        }'
        
        response=$(curl -s -w "\n%{http_code}" -X POST "$WEBHOOK_URL" \
            -H 'Content-Type: application/json' \
            -d "$test_payload" 2>&1)
        
        http_code=$(echo "$response" | tail -n1)
        
        if echo "$http_code" | grep -qE "^(200|204)$"; then
            echo -e "${GREEN}✓ Webhook test successful!${NC}"
            
            # Add to bashrc
            BASHRC_ENTRY="export DISCORD_WEBHOOK_URL=\"$WEBHOOK_URL\""
            if ! grep -F "$DISCORD_WEBHOOK_URL" ~/.bashrc >/dev/null 2>&1; then
                echo "" >> ~/.bashrc
                echo "# Service Monitor Discord Webhook" >> ~/.bashrc
                echo "$BASHRC_ENTRY" >> ~/.bashrc
                echo -e "${GREEN}✓ Webhook URL added to ~/.bashrc${NC}"
            fi
            
            # Export for current session
            export DISCORD_WEBHOOK_URL="$WEBHOOK_URL"
            echo -e "${GREEN}✓ Webhook URL configured for current session${NC}"
        else
            echo -e "${RED}✗ Webhook test failed (HTTP $http_code)${NC}"
            echo "Check the URL and try again"
        fi
    else
        echo -e "${YELLOW}⊘ Skipping Discord configuration${NC}"
    fi
else
    echo -e "${YELLOW}⊘ Skipping Discord configuration${NC}"
fi

echo ""

#===============================================================================
# Crontab Configuration
#===============================================================================

echo -e "${BLUE}Step 4: Crontab Configuration${NC}"
echo ""

echo "How often should the monitor check services?"
echo "1) Every 5 minutes (recommended for production)"
echo "2) Every 15 minutes"
echo "3) Every hour"
echo "4) Every 6 hours"
echo "5) Daily at 2 AM"
echo "6) Custom"
echo "0) Skip crontab setup"
echo ""

read -p "Select option (0-6): " CRON_OPTION

case $CRON_OPTION in
    1)
        CRON_ENTRY="*/5 * * * * $MONITOR_SCRIPT"
        CRON_DESC="every 5 minutes"
        ;;
    2)
        CRON_ENTRY="*/15 * * * * $MONITOR_SCRIPT"
        CRON_DESC="every 15 minutes"
        ;;
    3)
        CRON_ENTRY="0 * * * * $MONITOR_SCRIPT"
        CRON_DESC="every hour"
        ;;
    4)
        CRON_ENTRY="0 */6 * * * $MONITOR_SCRIPT"
        CRON_DESC="every 6 hours"
        ;;
    5)
        CRON_ENTRY="0 2 * * * $MONITOR_SCRIPT"
        CRON_DESC="daily at 2 AM"
        ;;
    6)
        read -p "Enter crontab expression (e.g., '*/5 * * * *'): " CRON_TIME
        CRON_ENTRY="$CRON_TIME $MONITOR_SCRIPT"
        CRON_DESC="custom ($CRON_TIME)"
        ;;
    0)
        echo -e "${YELLOW}⊘ Skipping crontab configuration${NC}"
        CRON_OPTION="skip"
        ;;
    *)
        echo -e "${RED}Invalid option${NC}"
        CRON_OPTION="skip"
        ;;
esac

if [ "$CRON_OPTION" != "skip" ] && [ "$CRON_OPTION" != "0" ]; then
    # Check if already in crontab
    if crontab -l 2>/dev/null | grep -F "$MONITOR_SCRIPT" >/dev/null; then
        echo -e "${YELLOW}⚠ Service monitor is already in crontab${NC}"
        read -p "Replace it with new schedule? (y/n): " -r REPLACE_CRON
        if [[ $REPLACE_CRON =~ ^[Yy]$ ]]; then
            # Remove old entry
            (crontab -l 2>/dev/null | grep -F -v "$MONITOR_SCRIPT"; echo "$CRON_ENTRY") | crontab -
            echo -e "${GREEN}✓ Crontab updated ($CRON_DESC)${NC}"
        else
            echo -e "${YELLOW}⊘ Keeping existing crontab entry${NC}"
        fi
    else
        # Add new entry
        (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
        echo -e "${GREEN}✓ Crontab configured ($CRON_DESC)${NC}"
    fi
else
    echo -e "${YELLOW}⊘ Crontab not configured${NC}"
fi

echo ""

#===============================================================================
# Setup sudoers for systemctl
#===============================================================================

echo -e "${BLUE}Step 5: Sudoers Configuration (optional)${NC}"
echo ""
echo "For automatic restart of systemctl services (flask-api.service, bot.service),"
echo "you need to allow password-less sudo access."
echo ""

read -p "Configure sudoers for password-less systemctl? (y/n): " -r SETUP_SUDO

if [[ $SETUP_SUDO =~ ^[Yy]$ ]]; then
    CURRENT_USER=$(whoami)
    echo ""
    echo "Creating sudoers entry for $CURRENT_USER..."
    echo "You may be prompted for your password."
    echo ""
    
    # Create temporary sudoers file
    TEMP_SUDOERS=$(mktemp)
    cat > "$TEMP_SUDOERS" <<EOF
# Service Monitor - password-less systemctl commands
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl start flask-api.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl start bot.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl is-active flask-api.service
$CURRENT_USER ALL=(ALL) NOPASSWD: /bin/systemctl is-active bot.service
EOF
    
    # Use visudo to merge with existing sudoers
    sudo bash -c "cat $TEMP_SUDOERS >> /etc/sudoers.d/service-monitor" 2>/dev/null && \
    echo -e "${GREEN}✓ Sudoers configured${NC}" || \
    echo -e "${RED}✗ Failed to configure sudoers${NC}"
    
    rm -f "$TEMP_SUDOERS"
else
    echo -e "${YELLOW}⊘ Skipping sudoers configuration${NC}"
fi

echo ""

#===============================================================================
# Test Run
#===============================================================================

echo -e "${BLUE}Step 6: Test Run${NC}"
echo ""
read -p "Run a test of the monitoring script? (y/n): " -r RUN_TEST

if [[ $RUN_TEST =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Running test with verbose output...${NC}"
    echo ""
    VERBOSE=1 bash "$MONITOR_SCRIPT" 2>&1 | head -50
    echo ""
    if [ -f "$PROJECT_DIR/logs/service_monitor.log" ]; then
        echo -e "${YELLOW}Last 10 log entries:${NC}"
        tail -10 "$PROJECT_DIR/logs/service_monitor.log"
    fi
else
    echo -e "${YELLOW}⊘ Skipping test run${NC}"
fi

echo ""

#===============================================================================
# Summary
#===============================================================================

echo -e "${BLUE}================================================${NC}"
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

echo -e "${BLUE}Next Steps:${NC}"
echo "1. Review SERVICE_MONITOR_README.md for detailed information"
echo "2. Verify crontab is running: ${YELLOW}crontab -l${NC}"
echo "3. Check logs: ${YELLOW}tail -f ~/Teeth-Management-System/logs/service_monitor.log${NC}"
echo "4. Monitor Discord for notifications"
echo ""

echo -e "${BLUE}Useful Commands:${NC}"
echo "  View logs:              ${YELLOW}tail -f $PROJECT_DIR/logs/service_monitor.log${NC}"
echo "  Run test:               ${YELLOW}VERBOSE=1 $MONITOR_SCRIPT${NC}"
echo "  View crontab:           ${YELLOW}crontab -l${NC}"
echo "  Edit crontab:           ${YELLOW}crontab -e${NC}"
echo "  Check cron status:      ${YELLOW}sudo systemctl status cron${NC}"
echo ""

echo -e "${GREEN}Service monitoring is now configured!${NC}"
echo ""
