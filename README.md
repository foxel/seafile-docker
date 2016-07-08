# seafile-docker
Seafile docker image for swift setup

## Getting started

* copy docker-compose.override.yml.sample to docker-compose.override.yml ans change with desired settings
* start the system with `docker-compose up -d`
* see `docker-compose logs mysql` to find out mysql root password (if you did not set it in docker-compose.override.yml)
* perform initial setup with `docker-compose exec seafile setup` (this will ask you for mysql root password)
