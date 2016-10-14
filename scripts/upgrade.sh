#!/bin/bash

set -e

UPGRADE_VERSION="$1"

SQL_BASE_PATH="/opt/seafile/latest/upgrade/sql/${UPGRADE_VERSION}/mysql"

for db in ccnet seafile seahub; do
    SQL_FILE="${SQL_BASE_PATH}/${db}.sql"
    if [ -f "${SQL_FILE}" ]; then
        mysql -hmysql -useafile -pseafile "${db}_db" < "${SQL_FILE}"
    fi
done
