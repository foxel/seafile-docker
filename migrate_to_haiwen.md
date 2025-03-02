# Overview

This is a guide to migrate from `foxel/seafile-docker` docker images 
 to images [provided by Haiwen](https://manual.seafile.com/latest/setup/setup_ce_by_docker/).
For quite some time the `foxel/seafile-docker` images were developed in parallel to the official ones 
 and based on binary installation guides provided by Haiwen.

This guide is intended for users of `foxel/seafile-docker` images who want to migrate to the official images.

This guide is written after the author's experience with the migration process. 
 It may not cover all possible scenarios depending on the customizations you have made to your setup.
 Read the guide carefully and make sure you understand the steps before proceeding.
 Be prepared to adjust the steps to your specific case.

# Prerequisites

The guide is prepared having Seafile version 11 in mind. Once migrated, you will be able to upgrade to newer versions 
 using the official guides.

First of all, make sure to have a backup of your data. The migration process will not touch your data, but it is always 
 good to have a backup.

The guide will operate some paths on the host file system:
- `/docker/seafile` - the data directory that was previously mounted to `/seafile` in the container.
- `/docker/seafile-shared` - the new data directory that will be mounted to `/shared` in the container.
- `/docker/seafile-mysql` - the new data directory for MySQL that will be mounted to the new database container.
- `/backups` - a directory where backups will be stored temporarily.

If you were using named volumes in your setup, you will need to adjust the paths accordingly:
 Replace `/docker/seafile` with the path to the named volume path, that you can find with `docker volume inspect ...`. 
 It will be like `/var/lib/docker/volumes/seafiledocker_seafile/_data`. 

# Migration steps

## Step 1. Perform MySQL backup

First, make sure to have a backup of your MySQL database. You can use `mysqldump` for that:

```shell
docker-compose exec mysql mysqldump -pseafile -useafile -n --opt --databases ccnet_db seafile_db seahub_db | \
  gzip > /backups/seafile-mysql.sql.gz
```

## Step 2. Stop the system

```shell
docker-compose down
```

## Step 3. Prepare the new directory structure

Haiwen images use a different directory structure. You will need to prepare the new directories:

```shell
mkdir -p /docker/seafile-shared
mv /docker/seafile /docker/seafile-shared/seafile
```

Haiwen images use uid 8000 for the seafile user when using `NON_ROOT` mode. 
 Make sure to change the ownership of the new directory:

```shell
chown -R 8000:8000  /docker/seafile-shared/seafile/
```

If you are not to use `NON_ROOT` mode, you need to change the ownership to the `root` user instead.

## Step 4. Prepare the new docker-compose.yml

The new `docker-compose.yml` file should look like this:

```yaml
services:
  db:
    image: mariadb:10.11
    restart: always
    container_name: seafile-mysql
    environment:
      - MYSQL_ROOT_PASSWORD=root-password  # Required, set the root's password of MySQL service.
      - MYSQL_LOG_CONSOLE=true
      - MARIADB_AUTO_UPGRADE=1
    volumes:
      - /docker/seafile-mysql:/var/lib/mysql  # Required, specifies the path to MySQL data persistent store.

  memcached:
    image: memcached:1.6.18
    restart: always
    container_name: seafile-memcached
    entrypoint: memcached -m 256

  seafile:
    image: seafileltd/seafile-mc:11.0-latest
    restart: always
    container_name: seafile
    ports:
      - "9080:80"
    volumes:
      - /docker/seafile-shared:/shared   # Required, specifies the path to Seafile data persistent store.
    environment:
      - NON_ROOT=true
      - DB_HOST=db
      - DB_ROOT_PASSWD=root-password  # Required, the value should be root's password of MySQL service.
      # - TIME_ZONE=Asia/Novosibirsk  # Optional, default is UTC. Should be uncommented and set to your local time zone.
      - SEAFILE_SERVER_LETSENCRYPT=false   # Whether to use https or not.
    depends_on:
      - db
      - memcached
```
## Step 5. Start and restore the database

Start the database container:

```shell
docker compose scale db=1
```

Create the user and databases (use the password you set in `docker-compose.yml`):

```shell
docker compose exec db mysql -uroot -p
```

```mysql
GRANT USAGE ON *.* TO `seafile`@`%.%.%.%` IDENTIFIED BY 'seafile';
CREATE DATABASE /*!32312 IF NOT EXISTS*/ `ccnet_db` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/ `seafile_db` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/ `seahub_db` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci */;
GRANT ALL PRIVILEGES ON `ccnet_db`.* TO `seafile`@`%.%.%.%`;
GRANT ALL PRIVILEGES ON `seahub_db`.* TO `seafile`@`%.%.%.%`;
GRANT ALL PRIVILEGES ON `seafile_db`.* TO `seafile`@`%.%.%.%`;
```
Restore the database:

```shell
zcat /backups/seafile-mysql.sql.gz | \
 sed -e 's/utf8mb4_0900_ai_ci/utf8mb4_general_ci/g' | \
 docker exec -i seafile-mysql mysql -h 127.0.0.1 -useafile -pseafile
```

## Step 6. Update the config files:

Change the database hostname from `mysql` to `db` in the `ccnet.conf`, `seafile.conf`, and `seahub_settings.py` files.
 Assuming you're using VIM editor:

```shell
vim /docker/seafile-shared/seafile/conf/ccnet.conf
```

```ini
[Database]
...
HOST = db
...
```

```shell
vim /docker/seafile-shared/seafile/conf/seafile.conf
```

```ini
[database]
...
host = db
...
```

```shell
vim /docker/seafile-shared/seafile/conf/seahub_settings.py
```

```python
DATABASES = {
    'default': {
        ...
        'HOST': 'db',
        ...
        'OPTIONS': {'charset': 'utf8mb4'},
    }
}
```

Also you need to set CSRF_TRUSTED_ORIGINS and remove THUMBNAIL_ROOT in `seahub_settings.py`:

```python
SERVICE_URL = 'https://your.domain'
CSRF_TRUSTED_ORIGINS = [SERVICE_URL]
# remove THUMBNAIL_ROOT
```

## Step 7. Start the system

```shell
docker-compose up -d
```

During the start seafile container will be stuck at `Create linux user seafile in container, please wait.`. 
 This is expected due to NON_ROOT used, just wait for the container to start.
 This will also happen every time you recreate the container, either after upgrade or any compose file change.
