#!/usr/bin/env bash

################################################################################
# Service Monitor Crontab Cleanup Script
# Purpose: Remove duplicate cron entries for service_monitor.sh
# Usage: bash cleanup_crontab.sh
################################################################################

set -o pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MONITOR_SCRIPT="$PROJECT_DIR/service_monitor.sh"

# Colors
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

#===============================================================================
# Helper Functions
#===============================================================================

print_header() {
    echo -e "${BLUE}================================================${NC}"
    echo -e "${BLUE}  Service Monitor Crontab Cleanup${NC}"
    echo -e "${BLUE}================================================${NC}"
    echo ""
}

count_monitor_entries() {
    crontab -l 2>/dev/null | grep -c "$MONITOR_SCRIPT" || echo 0
}

#===============================================================================
# Main
#===============================================================================

print_header

echo "Checking for duplicate cron entries..."
echo ""

# Get current crontab
CURRENT_CRONTAB=$(crontab -l 2>/dev/null)
MONITOR_COUNT=$(count_monitor_entries)

if [ "$MONITOR_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}No cron entries found for $MONITOR_SCRIPT${NC}"
    echo ""
    read -p "Add a new cron entry? (y/n): " -r ADD_ENTRY
    if [[ $ADD_ENTRY =~ ^[Yy]$ ]]; then
        echo ""
        echo "Select monitoring frequency:"
        echo "1) Every 5 minutes (recommended)"
        echo "2) Every 15 minutes"
        echo "3) Every hour"
        echo ""
        read -p "Select option (1-3): " FREQ_OPTION
        
        case $FREQ_OPTION in
            1) CRON_TIME="*/5 * * * *" ;;
            2) CRON_TIME="*/15 * * * *" ;;
            3) CRON_TIME="0 * * * *" ;;
            *) CRON_TIME="*/5 * * * *" ;;
        esac
        
        (crontab -l 2>/dev/null; echo "$CRON_TIME $MONITOR_SCRIPT") | crontab -
        echo -e "${GREEN}✓ Cron entry added: $CRON_TIME $MONITOR_SCRIPT${NC}"
    fi
elif [ "$MONITOR_COUNT" -eq 1 ]; then
    echo -e "${GREEN}✓ Only one cron entry found (correct)${NC}"
    echo ""
    echo "Current cron entry:"
    echo "$CURRENT_CRONTAB" | grep "$MONITOR_SCRIPT"
else
    echo -e "${RED}⚠ Found $MONITOR_COUNT duplicate cron entries!${NC}"
    echo ""
    echo "Current entries:"
    echo "$CURRENT_CRONTAB" | grep -n "$MONITOR_SCRIPT"
    echo ""
    
    read -p "Remove all duplicate entries and keep only one? (y/n): " -r CLEANUP
    
    if [[ $CLEANUP =~ ^[Yy]$ ]]; then
        echo ""
        echo "Select monitoring frequency for the single entry:"
        echo "1) Every 5 minutes (recommended)"
        echo "2) Every 15 minutes"
        echo "3) Every hour"
        echo ""
        read -p "Select option (1-3): " FREQ_OPTION
        
        case $FREQ_OPTION in
            1) CRON_TIME="*/5 * * * *" ;;
            2) CRON_TIME="*/15 * * * *" ;;
            3) CRON_TIME="0 * * * *" ;;
            *) CRON_TIME="*/5 * * * *" ;;
        esac
        
        # Remove all monitor entries and add back one
        (echo "$CURRENT_CRONTAB" | grep -v "$MONITOR_SCRIPT"; echo "$CRON_TIME $MONITOR_SCRIPT") | crontab -
        
        NEW_COUNT=$(count_monitor_entries)
        if [ "$NEW_COUNT" -eq 1 ]; then
            echo -e "${GREEN}✓ Cleanup complete! Single cron entry configured.${NC}"
            echo ""
            echo "New cron entry:"
            crontab -l 2>/dev/null | grep "$MONITOR_SCRIPT"
        else
            echo -e "${RED}✗ Cleanup failed${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Cleanup cancelled${NC}"
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}Verify the crontab:${NC}"
echo "$ crontab -l"
echo ""
echo -e "${BLUE}Monitor the logs:${NC}"
echo "$ tail -f $PROJECT_DIR/logs/service_monitor.log"
echo ""
