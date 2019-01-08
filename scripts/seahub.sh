#!/bin/bash

if [ ! -f "/seafile/conf/seahub_settings.py" ]; then
    exit 0
fi

. /scripts/seafile-env.sh

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

manage_py="${INSTALLPATH}/seahub/manage.py"
gunicorn_conf=${INSTALLPATH}/runtime/seahub.conf
gunicorn_exe=${INSTALLPATH}/seahub/thirdpart/gunicorn

errorlog="${TOPDIR}/logs/seahub-error.log"
accesslog="${TOPDIR}/logs/seahub-access.log"

mkdir -p "${TOPDIR}/logs"

exec python "${gunicorn_exe}" seahub.wsgi:application \
    -c "${gunicorn_conf}" -b "0.0.0.0:8000" --preload \
    --error-logfile "${errorlog}" \
    --access-logfile "${accesslog}" \
    --pid "/var/run/seafile/seahub.pid"
