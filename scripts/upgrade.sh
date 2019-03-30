#!/bin/bash

set -e

UPGRADE_VERSION="$1"

SQL_BASE_PATH="/opt/seafile/latest/upgrade/sql/${UPGRADE_VERSION}/mysql"

. /scripts/seafile-setup-env.sh

# stop server
[ -f /var/run/supervisord.pid ] && supervisorctl stop main:*

CCNET_SQL_FILE="${SQL_BASE_PATH}/ccnet.sql"
if [ -f "${CCNET_SQL_FILE}" ]; then
    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_USER_PASSWD} "${CCNET_DB}" < "${CCNET_SQL_FILE}"
fi

SEAFILE_SQL_FILE="${SQL_BASE_PATH}/seafile.sql"
if [ -f "${SEAFILE_SQL_FILE}" ]; then
    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_USER_PASSWD} "${SEAFILE_DB}" < "${SEAFILE_SQL_FILE}"
fi

SEAHUB_SQL_FILE="${SQL_BASE_PATH}/seahub.sql"
if [ -f "${SEAHUB_SQL_FILE}" ]; then
    mysql -h${MYSQL_HOST} -u${MYSQL_USER} -p${MYSQL_USER_PASSWD} "${SEAHUB_DB}" < "${SEAHUB_SQL_FILE}"
fi

# making sure directories are in place
mkdir -p /seafile/seahub-data/custom \
    /seafile/seahub-data/CACHE \
    /seafile/logs

# starting server
[ -f /var/run/supervisord.pid ] && supervisorctl start main:*

echo "Done"
