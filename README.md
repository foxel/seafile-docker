# seafile-docker
Seafile docker image for swift setup

## Quickstart

* Write the following `docker-compose.yml` configuration. You should change environment variables as needed.

```
version: '2.2'
services:
  seafile:
    image: foxel/seafile:6.3.3
    ports:
      - "9080:80"
    environment:
      MYSQL_ROOT_PASSWORD: 'my-root-secret'
      ADMIN_EMAIL: 'admin@example.com'
      ADMIN_PASSWORD: 'admin'
      SEAFILE_URL: 'http://seafile.example.com'
    volumes:
      - seafile-ccnet:/seafile/ccnet
      - seafile-seafile-data:/seafile/seafile-data
      - seafile-seahub-data:/seafile/seahub-data
      - seafile-conf:/seafile/conf
  mysql:
    environment:
      MYSQL_ROOT_PASSWORD: 'my-root-secret'
    volumes:
      - mysql:/var/lib/mysql
    image: mysql:5.7
volumes:
  mysql: ~
  seafile-ccnet: ~
  seafile-seafile-data: ~
  seafile-seahub-data: ~
  seafile-conf: ~
```

* Start the services with `docker-compose up -d`

* Connect to http://localhost:9080 and login with provided `ADMIN_EMAIL` and `ADMIN_PASSWORD` values.

## Without sensitive environment variables

If you mind using variables containing passwords, you can install seafile in two steps.

* Write the following `docker-compose.yml` configuration.

```
version: '2.2'
services:
  seafile:
    image: foxel/seafile:6.3.3
    ports:
      - "9080:80"
    environment:
      SEAFILE_URL: 'http://seafile.example.com'
    volumes:
      - seafile:/seafile
  mysql:
    volumes:
      - mysql:/var/lib/mysql
    image: mysql:5.7
volumes:
  mysql: ~
  seafile: ~
```

* Start the services with `docker-compose up -d`

* Check the generated mysql root password in docker logs

```
docker-compose logs mysql
```

* Run seafile setup by providing variables for the setup execution only.

```
docker-compose exec \
  -e MYSQL_ROOT_PASSWORD="mysql-generated-password" \
  -e ADMIN_EMAIL="admin@example.com" \
  -e ADMIN_PASSWORD="admin" \
  seafile setup
```

* Connect to http://localhost:9080 and login with provided `ADMIN_EMAIL` and `ADMIN_PASSWORD` values.

## Environment variables

- `MYSQL_ROOT_PASSWORD` (or `MYSQL_ROOT_PASSWD`)

Root password of the mysql database used during setup.

- `MYSQL_HOST` (default: `mysql`)

Docker service name of the mysql database.

- `ADMIN_EMAIL` (default: `admin@example.com`)

Default admin user email created during setup.

- `ADMIN_PASSWORD` (default: `admin`)

Default admin password created during setup.

- `USE_EXISTING_DB` (default: `0`)

Set to `1` if database already exists. This will create databases by default.

- `SERVER_NAME` (default: `seafile`)

Name of the seafile server.

- `CCNET_DB` (default: `ccnet-db`)

Ccnet database name.

- `SEAFILE_DB` (default: `seafile-db`)

Seafile database name.

- `SEAHUB_DB` (default: `seahub-db`)

Seahub database name.

## UPGRADING

Upgrading is possible in step-by-step manner:

### 6.2.x => 6.3.x
```
docker-compose exec seafile /scripts/upgrade.sh 6.3.0
```

### 6.1.x => 6.2.x
```
docker-compose exec seafile /scripts/upgrade.sh 6.2.0
```

### 6.0.x => 6.1.x
```
docker-compose exec seafile /scripts/upgrade.sh 6.1.0
```

### 5.1.x => 6.0.x
```
docker-compose exec seafile /scripts/upgrade.sh 6.0.0
```
