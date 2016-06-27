#!/bin/bash

set -e

if [ -f /seafile/.installed ]; then
    echo "Looks like seafile setup already complete"
    exit 1
fi

# clear installation
[ -f /var/run/supervisord.pid ] && supervisorctl stop all
rm -rf /seafile/*

MYSQL_ROOT_PW="$1"

[ -z "${MYSQL_ROOT_PW}" ] && echo "Now you will be asked for MySQL root password:"

mysql -hmysql -uroot -p${MYSQL_ROOT_PW} <<'EOF'
DROP DATABASE IF EXISTS `ccnet_db`;
DROP DATABASE IF EXISTS `seafile_db`;
DROP DATABASE IF EXISTS `seahub_db`;

CREATE DATABASE `ccnet_db` CHARACTER SET = 'utf8';
CREATE DATABASE `seafile_db` CHARACTER SET = 'utf8';
CREATE DATABASE `seahub_db` CHARACTER SET = 'utf8';

CREATE USER IF NOT EXISTS 'seafile'@'%' IDENTIFIED BY 'seafile';

GRANT ALL PRIVILEGES ON `ccnet_db`.* TO `seafile`@'%';
GRANT ALL PRIVILEGES ON `seafile_db`.* TO `seafile`@'%';
GRANT ALL PRIVILEGES ON `seahub_db`.* TO `seafile`@'%';

FLUSH PRIVILEGES;
EOF

# temporarily copy installation files to working dir
cp -r /opt/seafile-server-${SEAFILE_VESION} /seafile/seafile-server-${SEAFILE_VESION}

/seafile/seafile-server-${SEAFILE_VESION}/setup-seafile-mysql.sh auto -e 1 -n seafile \
    -p 8082 -o mysql -u seafile -w seafile \
    -c ccnet_db -s seafile_db -b seahub_db

# removing temporary copied installation and set up symlink
rm -rf /seafile/seafile-server-${SEAFILE_VESION}
rm /seafile/seafile-server-latest
ln -s /opt/seafile-server-${SEAFILE_VESION} /seafile/seafile-server-latest

read HOST_IP <<< `hostname -I`
[ -z "${SEAFILE_URL}" ] && SEAFILE_URL="http://${HOST_IP}"

sed -i "/SERVICE_URL = /c SERVICE_URL = ${SEAFILE_URL}" /seafile/conf/ccnet.conf
cat "FILE_SERVER_ROOT = '${SEAFILE_URL}/seafhttp'" >> /seafile/conf/seahub_settings.py

touch /seafile/.installed
[ -f /var/run/supervisord.pid ] && supervisorctl start all

echo "Now waiting for processes to start before creating admin user..."

sleep 10

exec /scripts/check-admin-user.sh


