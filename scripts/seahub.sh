#!/bin/bash

. /scripts/seafile-env.sh

manage_py="${INSTALLPATH}/seahub/manage.py"
errorlog="${TOPDIR}/logs/seahub-error.log"
accesslog="${TOPDIR}/logs/seahub-access.log"

mkdir -p "${TOPDIR}/logs"
exec python "${manage_py}" runfcgi host=127.0.0.1 port=8000 \
    daemonize=false \
    outlog=${accesslog} errlog=${errorlog}
