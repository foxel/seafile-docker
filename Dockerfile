FROM ubuntu:18.04

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        wget mysql-client nginx ffmpeg python3 python3-pip python3-setuptools \
        python3-pil python3-jinja2 python3-sqlalchemy \
        python3-ldap3 python3-mysqldb python3-pylibmc python3-urllib3 && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install supervisor iniparse \
        pillow moviepy captcha django-pylibmc django-simple-captcha && \
    apt-get remove -y --purge --autoremove python3-pip && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-enabled/*

# crudini for python3
RUN \
    wget -qO /usr/local/bin/crudini https://raw.githubusercontent.com/pixelb/crudini/0.9.3/crudini && \
    chmod +x /usr/local/bin/crudini

ENV SEAFILE_VERSION 7.1.4
ENV SEAFILE_PATH "/opt/seafile/$SEAFILE_VERSION"

RUN \
    mkdir -p /seafile "${SEAFILE_PATH}" && \
    wget --progress=dot:mega --no-check-certificate -O /tmp/seafile-server.tar.gz \
        "https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz" && \
    tar -xzf /tmp/seafile-server.tar.gz --strip-components=1 -C "${SEAFILE_PATH}" && \
    sed -ie '/^daemon/d' "${SEAFILE_PATH}/runtime/seahub.conf" && \
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
    chown seafile:seafile /run/seafile /opt/seafile/latest/runtime

WORKDIR "/seafile"

VOLUME "/seafile"

EXPOSE 80

CMD ["/scripts/startup.sh"]
