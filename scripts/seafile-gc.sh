#!/bin/bash

. /scripts/seafile-env.sh

seaf_gc=${INSTALLPATH}/seafile/bin/seafserv-gc

script_name=$0
function usage () {
    echo "usage : "
    echo "$(basename ${script_name}) [--dry-run | -D] [--rm-deleted | -r] [repo-id1] [repo-id2]"
    echo ""
}

if [[ $# -gt 0 ]]; then
    for param in $@; do
        if [ ${param} = "-h" -o ${param} = "--help" ]; then
            usage;
            exit 1;
        fi
    done
fi

# stop server
[[ -f /var/run/supervisord.pid ]] && supervisorctl stop all

"${seaf_gc}" \
    -c "${ccnet_conf_dir}" \
    -d "${seafile_data_dir}" \
    -F "${central_config_dir}" \
    "$@";

# starting server
[[ -f /var/run/supervisord.pid ]] && supervisorctl start all

echo "Done"
