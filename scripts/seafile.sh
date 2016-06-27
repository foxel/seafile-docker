#!/bin/bash

. /scripts/seafile-env.sh

seaf_controller="${INSTALLPATH}/seafile/bin/seafile-controller"

echo "Starting seafile server, please wait ..."
mkdir -p "${TOPDIR}/logs"
exec "${seaf_controller}" -f \
    -c "${ccnet_conf_dir}" \
    -d "${seafile_data_dir}" \
    -F "${central_config_dir}"

