### Backup, Restore and Sharing Rucio Postgres DB

This doc assumes Rucio DB is a Postgres DB.

#### Back Rucio DB

```
docker-compose -f etc/docker/dev/docker-compose.yml down
docker-compose -f etc/docker/dev/docker-compose.yml up -d ruciodb
docker exec -it dev_ruciodb_1 pg_dump -U rucio rucio > /tmp/rucio.sql # no need to backup DB postgres
```
The first two `docker-compose` commands may be skipped (not tested)

#### Restore Rucio DB

```
docker-compose -f etc/docker/dev/docker-compose.yml down
docker-compose -f etc/docker/dev/docker-compose.yml up -d ruciodb
echo drop database rucio | psql -U rucio postgres
echo create database rucio | psql -U rucio postgres
docker exec -it dev_ruciodb_1 psql -U rucio rucio < /tmp/rucio.sql
docker-compose -f etc/docker/dev/docker-compose.yml up -d
```

#### Sharing a Rucio DB with multple Rucio instances

Since a Postgres DB can contain different Schemas. It is possible (but not tested) to use one Rucio DB for multiple 
Rucio instances, with each instance using its own Schema name. The default Schema in the Rucio container is 'dev'. 
To use something different, update:
    * 'version_table_schema' in the [alembic] block of /opt/rucio/etc/alembic.ini
    * 'schema' in the [database] block of /opt/rucio/etc/rucio.cfg
