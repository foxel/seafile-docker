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

# fix symlink for avatars
if [ -d /seafile/seafile-server-latest/seahub/media/avatars ]; then
    rm -rf /seafile/seafile-server-latest/seahub/media/avatars
    ln -s /seafile/seahub-data/avatars /seafile/seafile-server-latest/seahub/media/avatars
fi

exec /usr/bin/supervisord -c /etc/supervisord.conf

