#!/bin/bash

. /scripts/seafile-env.sh

echo "Starting seafile notification server, please wait ..."
mkdir -p "${TOPDIR}/logs"
exec "${INSTALLPATH}/seafile/bin/notification-server" \
    -c "${central_config_dir}" \
    -l "${TOPDIR}/logs/notification-server.log"
