#!/bin/bash

if [ ! -f /seafile/.installed ]; then
    ln -s /scripts/setup.sh /bin/setup

    echo "Please run setup. e.g. docker-compose exec seafile setup"
    while [ ! -f /seafile/.installed ]; do
        sleep 1
    done

    echo "Looks like setup complete. Resuming startup..."
    rm /bin/setup
fi

[ -z "${MYSQL_HOST}" ] && MYSQL_HOST="mysql"

echo "Waiting for MySQL..."
while ! mysqladmin ping -h${MYSQL_HOST} -useafile -pseafile --silent; do
    sleep 1
done

# fix seahub symlinks
if [ ! -L ${SEAFILE_PATH}/seahub/media/avatars ]; then
    rm -rf ${SEAFILE_PATH}/seahub/media/avatars
    ln -s /seafile/seahub-data/avatars ${SEAFILE_PATH}/seahub/media/avatars
fi

if [ ! -L ${SEAFILE_PATH}/seahub/media/custom ]; then
    rm -rf ${SEAFILE_PATH}/seahub/media/custom
    ln -s /seafile/seahub-data/custom ${SEAFILE_PATH}/seahub/media/custom
fi

if [ ! -L ${SEAFILE_PATH}/seahub/media/CACHE ]; then
    rm -rf ${SEAFILE_PATH}/seahub/media/CACHE
    ln -s /seafile/seahub-data/CACHE ${SEAFILE_PATH}/seahub/media/CACHE
fi

# fix seafile install path symlinks
for folder in ccnet conf logs seafile-data seahub-data; do
   [ -L /opt/seafile/${folder} ] || ln -s /seafile/${folder} /opt/seafile/${folder}
done

exec /usr/bin/supervisord -c /etc/supervisord.conf

