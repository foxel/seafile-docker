#!/bin/bash

. /scripts/seafile-env.sh

seaf_fsck=${INSTALLPATH}/seafile/bin/seaf-fsck

script_name=$0
function usage () {
    echo "usage : "
    echo "$(basename ${script_name}) [-h/--help] [-r/--repair] [-E/--export path_to_export] [repo_id_1 [repo_id_2 ...]]"
    echo ""
}

if [ $# -gt 0 ]; then
    for param in $@; do
        if [ ${param} = "-h" -o ${param} = "--help" ]; then
            usage;
            exit 1;
        fi
    done
fi

# stop server
[ -f /var/run/supervisord.pid ] && supervisorctl stop all

ARGS=''
for i in "$@"; do
    i="${i//\\/\\\\}"
    ARGS="$ARGS '${i//\'/\\\'}'"
done

LD_LIBRARY_PATH=$SEAFILE_LD_LIBRARY_PATH su -s /bin/bash seafile -p -c "${seaf_fsck} \
    -c \"${ccnet_conf_dir}\" \
    -d \"${seafile_data_dir}\" \
    -F \"${central_config_dir}\" \
    ${ARGS}";

# starting server
[ -f /var/run/supervisord.pid ] && supervisorctl start all

echo "Done"
