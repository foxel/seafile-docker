#!/bin/bash

. /scripts/seafile-env.sh

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
