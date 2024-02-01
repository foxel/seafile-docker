FROM ubuntu:22.04 as builder
RUN apt-get update

RUN apt-get install --no-install-recommends -y \
        python3 python3-pip python3-setuptools python3-wheel \
        libmysqlclient-dev libsasl2-dev libldap2-dev python3-dev build-essential pkg-config

RUN pip3 wheel --no-cache-dir mysqlclient==2.1.*

RUN pip3 wheel --no-cache-dir python-ldap==3.4.3

FROM ubuntu:22.04

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

COPY --from=builder /mysqlclient-*.whl /python_ldap-*.whl /tmp/

RUN \
    apt-get update && \
    apt-get install --no-install-recommends -y \
        wget mysql-client libmysqlclient21 libldap-2.5-0 ldap-utils nginx ffmpeg python3 python3-pip python3-setuptools \
        python3-pil python3-jinja2 python3-sqlalchemy python3-future python3-markupsafe python3-pycryptodome \
        python3-ldap3 python3-pylibmc python3-urllib3 python3-lxml python3-cffi && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install --no-cache-dir supervisor iniparse \
        pillow==10.0.* moviepy captcha==0.4 django-pylibmc django-simple-captcha==0.5.* \
        djangosaml2==1.5.* pysaml2==7.2.* \
        /tmp/mysqlclient-*.whl /tmp/python_ldap-*.whl && \
    apt-get remove -y --purge --autoremove python3-pip && \
    rm -rf /var/lib/apt/lists/* && \
    rm -f /etc/nginx/sites-enabled/*

# crudini for python3
RUN \
    wget -qO /usr/local/bin/crudini https://raw.githubusercontent.com/pixelb/crudini/0.9.3/crudini && \
    chmod +x /usr/local/bin/crudini

ENV SEAFILE_VERSION 11.0.4
ENV SEAFILE_PATH "/opt/seafile/$SEAFILE_VERSION"

RUN \
    mkdir -p /seafile "${SEAFILE_PATH}" && \
    wget --progress=dot:mega --no-check-certificate -O /tmp/seafile-server.tar.gz \
        "https://download.seadrive.org/seafile-server_${SEAFILE_VERSION}_x86-64.tar.gz" && \
    tar -xzf /tmp/seafile-server.tar.gz --strip-components=1 -C "${SEAFILE_PATH}" && \
    sed -ie '/^daemon/d' "${SEAFILE_PATH}/runtime/seahub.conf" && \
    rm /tmp/seafile-server.tar.gz

# patches v10.0.0
RUN \
    rm "${SEAFILE_PATH}/seafile/lib/libstdc++.so.6" && \
    sed -i -e 's/ INDEX IF NOT EXISTS/ INDEX/' "${SEAFILE_PATH}/upgrade/sql/10.0.0/mysql/seafile.sql"

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
