#!/bin/bash

# Quick Oracle SYSDBA Connection Test
# Run this to verify sys user can connect with SYSDBA privileges

DB_USER="sys"
DB_PASSWORD="YOUR_DB_PASSWORD_HERE"  # Replace with actual password
DB_ORACLE_SID="XE"
ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"

echo "Testing SYSDBA connection..."
echo "Command: $ORACLE_HOME/bin/sqlplus -S $DB_USER/***@$DB_ORACLE_SID as sysdba"

export ORACLE_HOME="$ORACLE_HOME"
export PATH="$ORACLE_HOME/bin:$PATH"
export ORACLE_SID="$DB_ORACLE_SID"

if [ "$DB_PASSWORD" = "YOUR_DB_PASSWORD_HERE" ]; then
    echo "ERROR: Please set the actual database password in this script"
    exit 1
fi

# Test SYSDBA connection
"$ORACLE_HOME/bin/sqlplus" -S "$DB_USER/$DB_PASSWORD@$DB_ORACLE_SID as sysdba" << 'EOF'
SELECT 'SYSDBA_CONNECTION_OK: ' || instance_name || ' (' || status || ')' FROM v$instance;
SELECT 'USER: ' || user FROM dual;
EXIT;
EOF

echo ""
echo "If you see 'SYSDBA_CONNECTION_OK' above, the connection works."
echo "If you get errors, check the password and Oracle status."