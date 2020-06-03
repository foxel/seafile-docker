#!/bin/bash

. /scripts/seafile-env.sh

manage_py="${INSTALLPATH}/seahub/manage.py"
gunicorn_exe=${INSTALLPATH}/seahub/thirdpart/bin/gunicorn

errorlog="${TOPDIR}/logs/seahub-error.log"
accesslog="${TOPDIR}/logs/seahub-access.log"

mkdir -p "${TOPDIR}/logs"

exec python "${gunicorn_exe}" seahub.wsgi:application \
    -b "0.0.0.0:8000" \
    --preload \
    --workers 5 \
    --timeout 1200 \
    --limit-request-line 8190 \
    --error-logfile "${errorlog}" \
    --access-logfile "${accesslog}" \
    --pid "/var/run/seafile/seahub.pid"
