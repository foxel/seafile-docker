#!/bin/bash

set -e

if [ -f /seafile/.installed ]; then
    exit 0
fi

. /scripts/seafile-setup-env.sh

[ -z "${SERVER_IP}" ] && SERVER_IP="127.0.0.1"
[ -z "${FILESERVER_PORT}" ] && FILESERVER_PORT="8082"
[ -z "${SEAFILE_DIR}" ] && SEAFILE_DIR="8082"

SETUP_SEAFILE_MYSQL_ARGS="auto -e ${USE_EXISTING_DB} -n ${SERVER_NAME} -p ${FILESERVER_PORT} -o ${MYSQL_HOST} -u ${MYSQL_USER}  -w ${MYSQL_USER_PASSWD} -q ${MYSQL_USER_HOST} -c ${CCNET_DB} -s ${SEAFILE_DB} -b ${SEAHUB_DB}"
if [ ! -z "${MYSQL_ROOT_PASSWD}" ]; then
    SETUP_SEAFILE_MYSQL_ARGS="${SETUP_SEAFILE_MYSQL_ARGS} -r ${MYSQL_ROOT_PASSWD}"
else
    if [[ "${USE_EXISTING_DB}" != "1" ]]; then
        echo "MYSQL_ROOT_PASSWD environment variable is undefined. Please provide MYSQL_ROOT_PASSWD environment variable when starting the container. You may also run the setup manually (e.g. docker-compose exec -e MYSQL_ROOT_PASSWD=my-root-secret seafile setup)"
        exit 1
    fi
fi

echo "Running setup."

# clear installation
[ -f /var/run/supervisord.pid ] && supervisorctl stop main:*
rm -rf /seafile/*

# temporarily copy installation files to working dir
cp -r "${SEAFILE_PATH}" /seafile/seafile-server

/seafile/seafile-server/setup-seafile-mysql.sh ${SETUP_SEAFILE_MYSQL_ARGS}

# removing temporary copied installation and set up symlink
rm -rf /seafile/seafile-server
rm /seafile/seafile-server-latest

. /scripts/setup-config.sh

mkdir -p /seafile/seahub-data/custom \
    /seafile/seahub-data/CACHE \
    /seafile/logs

touch /seafile/.installed
[ -f /var/run/supervisord.pid ] && supervisorctl start main:*

echo "Now waiting for processes to start before creating admin user..."
sleep 10
exec /scripts/check-admin-user.sh
