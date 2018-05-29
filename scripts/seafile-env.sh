#!/bin/bash

TOPDIR="/seafile"
INSTALLPATH="${SEAFILE_PATH}"
ccnet_conf_dir="${TOPDIR}/ccnet"
central_config_dir="${TOPDIR}/conf"
seafile_ini="${ccnet_conf_dir}/seafile.ini"
seafile_data_dir=$(cat "${seafile_ini}")

export CCNET_CONF_DIR="${ccnet_conf_dir}"
export SEAFILE_CONF_DIR="${seafile_data_dir}"
export SEAFILE_CENTRAL_CONF_DIR="${central_config_dir}"
export PYTHONPATH="${INSTALLPATH}/seafile/lib/python2.6/site-packages:${INSTALLPATH}/seafile/lib64/python2.6/site-packages:${INSTALLPATH}/seahub:${INSTALLPATH}/seahub/thirdpart:$PYTHONPATH"
export PYTHONPATH="${INSTALLPATH}/seafile/lib/python2.7/site-packages:${INSTALLPATH}/seafile/lib64/python2.7/site-packages:$PYTHONPATH"

export PATH="${INSTALLPATH}/seafile/bin:$PATH"
export ORIG_LD_LIBRARY_PATH="${LD_LIBRARY_PATH}"
export SEAFILE_LD_LIBRARY_PATH="${INSTALLPATH}/seafile/lib/:${INSTALLPATH}/seafile/lib64:${LD_LIBRARY_PATH}"
export LD_LIBRARY_PATH="${SEAFILE_LD_LIBRARY_PATH}"
export SEAHUB_LOG_DIR="${TOPDIR}/logs"
