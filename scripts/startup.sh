#!/bin/bash

if [ ! -d /seafile/.installed ]; then
    ln -s /scripts/setup.sh /bin/setup

    echo "Please run setup. e.g. docker-compose exec seafile setup"
    while [ ! -f /seafile/.installed ]; do
        sleep 1
    done

    echo "Looks like setup complete. Resuming startup..."
    rm /bin/setup
fi

# fix seahub symlinks
if [ ! -L /opt/seafile-server-${SEAFILE_VERSION}/seahub/media/avatars ]; then
    rm -rf /opt/seafile-server-${SEAFILE_VERSION}/seahub/media/avatars
    ln -s /seafile/seahub-data/avatars /opt/seafile-server-${SEAFILE_VERSION}/seahub/media/avatars
fi

if [ ! -L /opt/seafile-server-${SEAFILE_VERSION}/seahub/media/custom ]; then
    rm -rf /opt/seafile-server-${SEAFILE_VERSION}/seahub/media/custom
    ln -s /seafile/seahub-data/custom /opt/seafile-server-${SEAFILE_VERSION}/seahub/media/custom
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf

