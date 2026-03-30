#!/bin/bash

# Minimal Oracle Export Test
# Tests the exact expdp command that backup.sh uses

DB_USER="sys"
DB_PASSWORD="YOUR_DB_PASSWORD_HERE"  # Replace with actual password
DB_ORACLE_SID="XE"
ORACLE_HOME="/opt/oracle/product/21c/dbhomeXE"
EXPORT_PATH="${ORACLE_HOME}/bin"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "Testing Oracle Data Pump Export (same as backup.sh)..."
echo "Command: ${EXPORT_PATH}/expdp ${DB_USER}/${DB_PASSWORD}@${DB_ORACLE_SID} as sysdba full=y dumpfile=tms_full_${TIMESTAMP}_%U.dmp logfile=tms_export_${TIMESTAMP}.log directory=DATA_PUMP_DIR parallel=4 exclude=statistics flashback_time=\"TO_TIMESTAMP(SYSDATE,'DD-MM-YYYY HH24:MI:SS')\""

if [ "$DB_PASSWORD" = "YOUR_DB_PASSWORD_HERE" ]; then
    echo "ERROR: Please set the actual database password"
    exit 1
fi

export ORACLE_HOME="$ORACLE_HOME"
export PATH="$ORACLE_HOME/bin:$PATH"
export ORACLE_SID="$DB_ORACLE_SID"

# Test the exact export command from backup.sh
if sudo -u oracle env ORACLE_HOME="${ORACLE_HOME}" ORACLE_SID="${ORACLE_SID}" PATH="${ORACLE_HOME}/bin:\$PATH" "${EXPORT_PATH}/expdp" '/ as sysdba' \
     full=y \
     dumpfile="tms_full_${TIMESTAMP}_%U.dmp" \
     logfile="tms_export_${TIMESTAMP}.log" \
     directory="DATA_PUMP_DIR" \
     parallel=4 \
     exclude=statistics \
     flashback_time="TO_TIMESTAMP(SYSDATE,'DD-MM-YYYY HH24:MI:SS')" \
     2>&1 | head -20; then
    echo ""
    echo "Export command executed successfully"
    echo "Check /opt/oracle/admin/XE/dpdump/ for dump files and logs"
else
    echo ""
    echo "Export command failed"
    echo "Check the export log: /opt/oracle/admin/XE/dpdump/tms_export_${TIMESTAMP}.log"
fi