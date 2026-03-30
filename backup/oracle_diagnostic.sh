#!/bin/bash

################################################################################
# ORACLE DIAGNOSTIC SCRIPT
# Helps troubleshoot Oracle XE connection and export issues
################################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}  Oracle XE Diagnostic Tool${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Configuration (update these with your actual values)
DB_USER="sys"
DB_PASSWORD="YOUR_DB_PASSWORD_HERE"  # Replace with actual password
DB_HOST="localhost"
DB_PORT="1521"
DB_ORACLE_SID="XE"
ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"

echo -e "${YELLOW}Configuration:${NC}"
echo "  User: $DB_USER"
echo "  SID: $DB_ORACLE_SID"
echo "  Oracle Home: $ORACLE_HOME"
echo ""

# Check if Oracle binaries exist
echo -e "${YELLOW}1. Checking Oracle Installation:${NC}"
if [ -f "${ORACLE_HOME}/bin/sqlplus" ]; then
    echo -e "${GREEN}✓ sqlplus found at ${ORACLE_HOME}/bin/sqlplus${NC}"
else
    echo -e "${RED}✗ sqlplus not found at ${ORACLE_HOME}/bin/sqlplus${NC}"
    exit 1
fi

if [ -f "${ORACLE_HOME}/bin/expdp" ]; then
    echo -e "${GREEN}✓ expdp found at ${ORACLE_HOME}/bin/expdp${NC}"
else
    echo -e "${RED}✗ expdp not found at ${ORACLE_HOME}/bin/expdp${NC}"
    exit 1
fi

# Check if Oracle is running
echo ""
echo -e "${YELLOW}2. Checking Oracle Database Status:${NC}"
if pgrep -f smon.*$DB_ORACLE_SID > /dev/null; then
    echo -e "${GREEN}✓ Oracle database ($DB_ORACLE_SID) is running${NC}"
else
    echo -e "${RED}✗ Oracle database ($DB_ORACLE_SID) is not running${NC}"
    echo -e "${YELLOW}Start Oracle with: sudo systemctl start oracle-xe-21c${NC}"
    exit 1
fi

# Check password
echo ""
echo -e "${YELLOW}3. Checking Password Configuration:${NC}"
if [ "$DB_PASSWORD" = "YOUR_DB_PASSWORD_HERE" ]; then
    echo -e "${RED}✗ Password not configured. Please update DB_PASSWORD in the script.${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Password is configured${NC}"
fi

# Test database connection
echo ""
echo -e "${YELLOW}4. Testing Database Connection:${NC}"
export ORACLE_HOME="${ORACLE_HOME}"
export PATH="$ORACLE_HOME/bin:$PATH"
export ORACLE_SID="$DB_ORACLE_SID"

if "${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID}" << 'EOF' 2>/dev/null
SET HEADING OFF
SET FEEDBACK OFF
SELECT 'CONNECTION_OK: ' || instance_name || ' (' || status || ')' FROM v$instance;
EXIT;
EOF
then
    echo -e "${GREEN}✓ Database connection successful${NC}"
else
    echo -e "${RED}✗ Database connection failed${NC}"
    echo -e "${YELLOW}Possible issues:${NC}"
    echo "  - Incorrect password"
    echo "  - Wrong username (try 'sys' or 'system')"
    echo "  - Database not accepting connections"
    exit 1
fi

# Check DATA_PUMP_DIR
echo ""
echo -e "${YELLOW}5. Checking DATA_PUMP_DIR Configuration:${NC}"
DATAPUMP_DIR=$("${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID}" << 'EOF' 2>/dev/null | grep -v "^$" | tail -1
SET HEADING OFF
SET FEEDBACK OFF
SELECT directory_path FROM dba_directories WHERE directory_name = 'DATA_PUMP_DIR';
EXIT;
EOF
)

DATAPUMP_DIR=$(echo "$DATAPUMP_DIR" | tr -d '[:space:]')

if [ -n "$DATAPUMP_DIR" ]; then
    echo -e "${GREEN}✓ DATA_PUMP_DIR configured: $DATAPUMP_DIR${NC}"
    if [ -d "$DATAPUMP_DIR" ]; then
        echo -e "${GREEN}✓ DATA_PUMP_DIR directory exists${NC}"
        AVAILABLE_SPACE=$(df "$DATAPUMP_DIR" | tail -1 | awk '{print $4}')
        echo -e "${BLUE}Available space: $((AVAILABLE_SPACE * 1024)) bytes ($((AVAILABLE_SPACE / 1024 / 1024)) GB)${NC}"
        if [ "$AVAILABLE_SPACE" -lt 1048576 ]; then
            echo -e "${RED}✗ WARNING: Low disk space (< 1GB) in DATA_PUMP_DIR${NC}"
        fi
    else
        echo -e "${RED}✗ DATA_PUMP_DIR directory does not exist${NC}"
    fi
else
    echo -e "${RED}✗ DATA_PUMP_DIR not configured in database${NC}"
fi

# Check user privileges
echo ""
echo -e "${YELLOW}6. Checking User Privileges:${NC}"
PRIVILEGES=$("${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID}" << 'EOF' 2>/dev/null | grep -v "^$" | head -5
SET HEADING OFF
SET FEEDBACK OFF
SELECT granted_role FROM dba_role_privs WHERE grantee = UPPER('$DB_USER') AND granted_role = 'DBA'
UNION ALL
SELECT privilege FROM dba_sys_privs WHERE grantee = UPPER('$DB_USER') AND privilege LIKE '%EXPORT%'
UNION ALL
SELECT 'SYSDBA' FROM v$pwfile_users WHERE username = UPPER('$DB_USER');
EXIT;
EOF
)

if echo "$PRIVILEGES" | grep -q "SYSDBA\|DBA\|EXPORT"; then
    echo -e "${GREEN}✓ User has sufficient privileges for export${NC}"
else
    echo -e "${RED}✗ User may not have sufficient privileges for full export${NC}"
    echo -e "${YELLOW}Required: SYSDBA privilege or EXP_FULL_DATABASE role${NC}"
fi

# Test small export
echo ""
echo -e "${YELLOW}7. Testing Small Export:${NC}"
TEST_DUMP_DIR="/tmp/oracle_test_$$"
mkdir -p "$TEST_DUMP_DIR"

if "${ORACLE_HOME}/bin/expdp" "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID}" \
     tables=dual \
     dumpfile=test_export.dmp \
     logfile=test_export.log \
     directory=DATA_PUMP_DIR \
     2>/dev/null | grep -q "successfully completed"; then
    echo -e "${GREEN}✓ Small export test successful${NC}"
    rm -f /opt/oracle/admin/xe/dpdump/test_export.*
else
    echo -e "${RED}✗ Small export test failed${NC}"
    echo -e "${YELLOW}Check export log: /opt/oracle/admin/xe/dpdump/test_export.log${NC}"
fi

rm -rf "$TEST_DUMP_DIR"

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}Diagnostic complete. If all checks pass, try running backup.sh${NC}"
echo -e "${BLUE}============================================================${NC}"