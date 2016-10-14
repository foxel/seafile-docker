# seafile-docker
Seafile docker image for swift setup

## Getting started (docker-compose setup)
* prepare docker-compose.yml (see example below)
* start the system with `docker-compose up -d`
* see `docker-compose logs mysql` to find out mysql root password (if you did not set it in docker-compose.override.yml)
* perform initial setup with `docker-compose exec seafile setup` (this will ask you for mysql root password)

## docker-compose.yml example
```
version: '2'

services:
  seafile:
    image: foxel/seafile:5.1.4
    ports:
      - "9080:80"
    environment:
      SEAFILE_URL: 'http://seafile.example.com'
    links:
      - mysql
    volumes:
      - seafile:/seafile
  mysql:
    environment:
      MYSQL_RANDOM_ROOT_PASSWORD: 1
    volumes:
      - mysql:/var/lib/mysql
    image: mysql:5.7

volumes:
  mysql:
    driver: local
  seafile:
    driver: local
```
