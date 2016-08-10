FROM ubuntu:14.04

ENV \
    DEBIAN_FRONTEND=noninteractive \
    SEAFILE_VERSION=5.1.4

RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        wget mysql-client supervisor nginx crudini \
        python2.7 libpython2.7 python-setuptools python-imaging \
        python-ldap python-mysqldb python-memcache python-urllib3 && \
    update-locale LANG=C.UTF-8 && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-enabled/*

ENV SEAFILE_PATH "/opt/seafile/$SEAFILE_VERSION"

RUN \
    mkdir -p /seafile "${SEAFILE_PATH}" && \
    wget --progress=dot:mega --no-check-certificate -O /tmp/seafile-server.tar.gz \
        "https://bintray.com/artifact/download/seafile-org/seafile/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz" && \
    tar -xzf /tmp/seafile-server.tar.gz --strip-components=1 -C "${SEAFILE_PATH}" && \
    rm /tmp/seafile-server.tar.gz

COPY etc/ /etc/
COPY scripts/ /scripts/

RUN \
    chmod +x /scripts/*.sh && \
    mkdir -p /run/seafile && \
    ln -s /run/seafile /opt/seafile/pids && \
    ln -s "${SEAFILE_PATH}" /opt/seafile/latest && \
    ln -s /etc/nginx/sites-available/seafile.conf /etc/nginx/sites-enabled/seafile.conf && \
    mkdir -p /seafile && \
    # seafile user
    useradd -r -s /bin/false seafile && \
    chown seafile:seafile /run/seafile

WORKDIR "/seafile"

VOLUME "/seafile"

EXPOSE 80

CMD ["/scripts/startup.sh"]
