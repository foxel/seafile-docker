#!/bin/bash

set -e

UPGRADE_VERSION="$1"

SQL_BASE_PATH="/opt/seafile/latest/upgrade/sql/${UPGRADE_VERSION}/mysql"

# stop server
[[ -f /var/run/supervisord.pid ]] && supervisorctl stop all

# seafevents is for Pro only, ignored for now
for db in ccnet seafile seahub; do
    SQL_FILE="${SQL_BASE_PATH}/${db}.sql"
    if [[ -f "${SQL_FILE}" ]]; then
        mysql -hmysql -useafile -pseafile -f "${db}_db" < "${SQL_FILE}"
    fi
done

# making sure directories are in place
mkdir -p /seafile/seahub-data/custom \
    /seafile/seahub-data/CACHE \
    /seafile/logs

chown -R seafile:seafile /seafile/*

# starting server
[[ -f /var/run/supervisord.pid ]] && supervisorctl start all

echo "Done"
