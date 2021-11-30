#!/bin/bash

TOPDIR="/seafile"
INSTALLPATH="${SEAFILE_PATH}"
ccnet_conf_dir="${TOPDIR}/ccnet"
central_config_dir="${TOPDIR}/conf"
seafile_data_dir="${TOPDIR}/seafile-data"
seafile_rpc_pipe_path=${INSTALLPATH}/runtime

export CCNET_CONF_DIR="${ccnet_conf_dir}"
export SEAFILE_CONF_DIR="${seafile_data_dir}"
export SEAFILE_CENTRAL_CONF_DIR="${central_config_dir}"
export SEAFILE_RPC_PIPE_PATH=${seafile_rpc_pipe_path}
export PYTHONPATH="${INSTALLPATH}/seafile/lib/python3/site-packages:${INSTALLPATH}/seahub:${INSTALLPATH}/seahub/thirdpart:${PYTHONPATH}"
export PYTHONPATH="${PYTHONPATH}:${central_config_dir}"

export PATH="${INSTALLPATH}/seafile/bin:$PATH"
export SEAFILE_LD_LIBRARY_PATH=${INSTALLPATH}/seafile/lib/:${INSTALLPATH}/seafile/lib64:${LD_LIBRARY_PATH}
export LD_LIBRARY_PATH="${SEAFILE_LD_LIBRARY_PATH}"
export SEAHUB_LOG_DIR="${TOPDIR}/logs"
