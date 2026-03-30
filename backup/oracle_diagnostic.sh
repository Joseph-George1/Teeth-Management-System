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

# Test database connection with SYSDBA
echo ""
echo -e "${YELLOW}4. Testing Database Connection (SYSDBA):${NC}"
export ORACLE_HOME="${ORACLE_HOME}"
export PATH="$ORACLE_HOME/bin:$PATH"
export ORACLE_SID="$DB_ORACLE_SID"

if "${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID} as sysdba" << 'EOF' 2>/dev/null
SET HEADING OFF
SET FEEDBACK OFF
SELECT 'CONNECTION_OK: ' || instance_name || ' (' || status || ')' FROM v$instance;
EXIT;
EOF
then
    echo -e "${GREEN}✓ SYSDBA connection successful${NC}"
else
    echo -e "${RED}✗ SYSDBA connection failed${NC}"
    echo -e "${YELLOW}Testing regular connection...${NC}"
    
    # Try regular connection
    if "${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID}" << 'EOF' 2>/dev/null
SET HEADING OFF
SET FEEDBACK OFF
SELECT 'CONNECTION_OK: ' || instance_name || ' (' || status || ')' FROM v$instance;
EXIT;
EOF
    then
        echo -e "${YELLOW}✓ Regular connection successful (but SYSDBA required for backup)${NC}"
        echo -e "${RED}✗ SYSDBA privileges required for backup operations${NC}"
        echo -e "${YELLOW}Use 'sys' user with 'as sysdba' for backup/restore${NC}"
        exit 1
    else
        echo -e "${RED}✗ Database connection failed${NC}"
        echo -e "${YELLOW}Possible issues:${NC}"
        echo "  - Incorrect password"
        echo "  - Wrong username (try 'sys' or 'system')"
        echo "  - Database not accepting connections"
        exit 1
    fi
fi

# Check DATA_PUMP_DIR
echo ""
echo -e "${YELLOW}5. Checking DATA_PUMP_DIR Configuration:${NC}"

# Query the database for DATA_PUMP_DIR with detailed debugging
DATAPUMP_RESULT=$("${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID} as sysdba" << 'EOF' 2>&1
SET HEADING OFF
SET FEEDBACK OFF
SET PAGESIZE 0
SELECT directory_path FROM dba_directories WHERE directory_name = 'DATA_PUMP_DIR';
EXIT;
EOF
)

# Clean up the result
DATAPUMP_DIR=$(echo "$DATAPUMP_RESULT" | grep -v "^$" | tail -1 | tr -d '[:space:]')

if [ -n "$DATAPUMP_DIR" ] && [ "$DATAPUMP_DIR" != "0" ]; then
    echo -e "${GREEN}✓ DATA_PUMP_DIR configured: $DATAPUMP_DIR${NC}"
    if [ -d "$DATAPUMP_DIR" ]; then
        echo -e "${GREEN}✓ DATA_PUMP_DIR directory exists${NC}"
        AVAILABLE_SPACE=$(df "$DATAPUMP_DIR" | tail -1 | awk '{print $4}')
        echo -e "${BLUE}Available space: $((AVAILABLE_SPACE * 1024)) bytes ($((AVAILABLE_SPACE / 1024 / 1024)) GB)${NC}"
        if [ "$AVAILABLE_SPACE" -lt 1048576 ]; then
            echo -e "${RED}✗ WARNING: Low disk space (< 1GB) in DATA_PUMP_DIR${NC}"
        fi
    else
        echo -e "${RED}✗ DATA_PUMP_DIR directory does not exist: $DATAPUMP_DIR${NC}"
    fi
else
    echo -e "${YELLOW}Checking if directory exists on filesystem...${NC}"
    if [ -d "/opt/oracle/admin/XE/dpdump" ]; then
        echo -e "${GREEN}✓ DATA_PUMP_DIR directory exists at /opt/oracle/admin/XE/dpdump${NC}"
        AVAILABLE_SPACE=$(df "/opt/oracle/admin/XE/dpdump" | tail -1 | awk '{print $4}')
        echo -e "${BLUE}Available space: $((AVAILABLE_SPACE * 1024)) bytes ($((AVAILABLE_SPACE / 1024 / 1024)) GB)${NC}"
    else
        echo -e "${RED}✗ DATA_PUMP_DIR not found in database query${NC}"
        echo -e "${YELLOW}Run: sudo ./oracle_setup_datapump.sh${NC}"
    fi
fi

# Check user privileges
echo ""
echo -e "${YELLOW}6. Checking User Privileges:${NC}"

# Since we're connecting as SYSDBA, we know the user has SYSDBA privileges
# Test by trying to query DBA views
PRIVILEGE_TEST=$("${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID} as sysdba" << 'EOF' 2>/dev/null | grep -v "^$" | head -1
SET HEADING OFF
SET FEEDBACK OFF
SELECT 'DBA_ACCESS_OK' FROM dba_users WHERE rownum = 1;
EXIT;
EOF
)

if [ "$PRIVILEGE_TEST" = "DBA_ACCESS_OK" ]; then
    echo -e "${GREEN}✓ User has SYSDBA privileges (can access DBA views)${NC}"
else
    echo -e "${RED}✗ User may not have sufficient DBA privileges${NC}"
    echo -e "${YELLOW}SYSDBA access test failed${NC}"
fi

# Test small export with SYSDBA
echo ""
echo -e "${YELLOW}7. Testing Small Export:${NC}"

# Drop test table if it exists, then create it
echo "Creating test table..."
"${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID} as sysdba" << 'EOF' 2>/dev/null
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE test_backup_table';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/
CREATE TABLE test_backup_table (id NUMBER, name VARCHAR2(50));
INSERT INTO test_backup_table VALUES (1, 'test');
COMMIT;
EXIT;
EOF

echo "Running export command: ${ORACLE_HOME}/bin/expdp / as sysdba tables=test_backup_table dumpfile=test_export.dmp logfile=test_export.log directory=DATA_PUMP_DIR"

if sudo -u oracle bash << EOFBASH 2>&1 | tee /tmp/export_output.log
export ORACLE_HOME='${ORACLE_HOME}'
export ORACLE_SID='${DB_ORACLE_SID}'
'${ORACLE_HOME}/bin/expdp' '/ as sysdba' tables=test_backup_table dumpfile=test_export.dmp logfile=test_export.log directory=DATA_PUMP_DIR
EOFBASH
if grep -q "successfully completed" /tmp/export_output.log; then
    echo -e "${GREEN}✓ Small export test successful${NC}"
    
    # Clean up test table
    "${ORACLE_HOME}/bin/sqlplus" -S "${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID} as sysdba" << 'EOF' 2>/dev/null
DROP TABLE test_backup_table;
EXIT;
EOF
    
else
    echo -e "${RED}✗ Small export test failed${NC}"
    echo -e "${YELLOW}Export command output:${NC}"
    cat /tmp/export_output.log 2>/dev/null || echo "No output captured"
    echo -e "${YELLOW}Check export log: /opt/oracle/admin/XE/dpdump/test_export.log${NC}"
fi

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${GREEN}Diagnostic complete. If all checks pass, try running backup.sh${NC}"
echo -e "${BLUE}============================================================${NC}"