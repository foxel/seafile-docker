#!/bin/bash

set -e

read HOST_IP <<< `hostname -I`
SEAFILE_URL="${SEAFILE_URL-http://${HOST_IP}}"

crudini --set /seafile/conf/ccnet.conf General SERVICE_URL "${SEAFILE_URL}"

crudini --merge /seafile/conf/seafile.conf <<'EOF'
[fileserver]
port = 8082
host = 127.0.0.1
EOF

crudini --merge /seafile/conf/seafdav.conf <<'EOF'
[WEBDAV]
enabled = true
port = 8080
host = 127.0.0.1
fastcgi = true
share_name = /seafdav/
EOF

cat >> /seafile/conf/seahub_settings.py <<EOF
ENABLE_SIGNUP = False
ACTIVATE_AFTER_REGISTRATION = False
FILE_SERVER_ROOT = '${SEAFILE_URL}/seafhttp'
ENABLE_THUMBNAIL = True
THUMBNAIL_ROOT = '/seafile/seahub-data/thumbnail/thumb/'
EOF