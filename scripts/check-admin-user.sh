#!/usr/bin/env bash

. /scripts/seafile-env.sh
. /scripts/seafile-setup-env.sh

if [[ ! -z "${ADMIN_EMAIL}" && ! -z \"${ADMIN_PASSWORD}\" ]]; then
  echo "{\"email\": \"${ADMIN_EMAIL}\", \"password\": \"${ADMIN_PASSWORD}\"}">"$SEAFILE_CENTRAL_CONF_DIR/admin.txt"
fi

python ${INSTALLPATH}/check_init_admin.py
