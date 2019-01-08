#!/bin/bash

if [ ! -f "/seafile/conf/seahub_settings.py" ]; then
    exit 0
fi

. /scripts/seafile-env.sh
. /scripts/seafile-setup-env.sh

if ! mysqladmin ping -h${MYSQL_HOST} -P${MYSQL_PORT} -u${MYSQL_USER} -p${MYSQL_USER_PASSWD} --silent; then
    echo "MySQL is not available."
    exit 1
fi

# fix seafile install path symlinks
for folder in ccnet conf logs seafile-data seahub-data; do
   [ -L "/opt/seafile/${folder}" ] || ln -s "/seafile/${folder}" "/opt/seafile/${folder}"
done

seaf_controller="${INSTALLPATH}/seafile/bin/seafile-controller"

echo "Starting seafile server, please wait ..."
mkdir -p "${TOPDIR}/logs"
exec "${seaf_controller}" -f \
    -c "${ccnet_conf_dir}" \
    -d "${seafile_data_dir}" \
    -F "${central_config_dir}"
