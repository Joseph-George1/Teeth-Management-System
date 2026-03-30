#!/bin/bash

################################################################################
# ORACLE DATA PUMP SETUP SCRIPT
# Creates DATA_PUMP_DIR and other necessary directories for backup/restore
################################################################################

DB_USER="sys"
DB_PASSWORD="YOUR_DB_PASSWORD_HERE"  # Replace with actual password
DB_ORACLE_SID="XE"
ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Oracle Data Pump Directory Setup${NC}"
echo ""

if [ "$DB_PASSWORD" = "YOUR_DB_PASSWORD_HERE" ]; then
    echo -e "${RED}ERROR: Please set DB_PASSWORD in this script${NC}"
    exit 1
fi

export ORACLE_HOME="$ORACLE_HOME"
export PATH="$ORACLE_HOME/bin:$PATH"
export ORACLE_SID="$DB_ORACLE_SID"

# Create physical directory
DATA_PUMP_DIR="/opt/oracle/admin/XE/dpdump"
echo "Creating DATA_PUMP_DIR: $DATA_PUMP_DIR"
mkdir -p "$DATA_PUMP_DIR"

# Make it writable by oracle user
chown -R oracle:oinstall "$DATA_PUMP_DIR" 2>/dev/null || true
chmod -R 770 "$DATA_PUMP_DIR" 2>/dev/null || true

echo -e "${GREEN}✓ Physical directory created${NC}"
echo ""

# Create database directory object
echo "Creating DATA_PUMP_DIR database object..."

"$ORACLE_HOME/bin/sqlplus" -S "$DB_USER/$DB_PASSWORD@$DB_ORACLE_SID as sysdba" << 'EOF'
SET HEADING OFF
SET FEEDBACK OFF

-- Drop if exists (ignore errors if doesn't exist)
BEGIN
    EXECUTE IMMEDIATE 'DROP DIRECTORY DATA_PUMP_DIR';
    DBMS_OUTPUT.PUT_LINE('Dropped existing DATA_PUMP_DIR');
EXCEPTION WHEN OTHERS THEN
    IF SQLCODE != -4305 THEN
        RAISE;
    END IF;
END;
/

-- Create the directory
CREATE DIRECTORY DATA_PUMP_DIR AS '/opt/oracle/admin/XE/dpdump';

-- Grant privileges
GRANT READ,WRITE ON DIRECTORY DATA_PUMP_DIR TO PUBLIC;

-- Verify
SELECT directory_name, directory_path FROM dba_directories WHERE directory_name = 'DATA_PUMP_DIR';

EXIT;
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ DATA_PUMP_DIR database object created successfully${NC}"
    echo ""
    echo "Verification:"
    "$ORACLE_HOME/bin/sqlplus" -S "$DB_USER/$DB_PASSWORD@$DB_ORACLE_SID as sysdba" << 'EOF'
SET HEADING OFF
SET FEEDBACK OFF
SELECT 'Directory: ' || directory_name || ' Path: ' || directory_path FROM dba_directories WHERE directory_name = 'DATA_PUMP_DIR';
EXIT;
EOF
else
    echo -e "${RED}✗ Failed to create DATA_PUMP_DIR database object${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}Setup complete. You can now run backup.sh${NC}"
