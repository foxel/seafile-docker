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

# enable the notification service for v10
if [[ "${UPGRADE_VERSION}" = "10.0.0" ]]; then
crudini --merge /seafile/conf/seafile.conf <<'EOF'
[notification]
enabled = true
host = 127.0.0.1
port = 8083
log_level = info
EOF

crudini --set /seafile/conf/seafile.conf notification jwt_private_key "$(openssl rand -base64 32)"
fi

# starting server
[[ -f /var/run/supervisord.pid ]] && supervisorctl start all

echo "Done"
