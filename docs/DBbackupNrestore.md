### Backup, Restore and Sharing Rucio Postgres DB

This doc assumes Rucio DB is a Postgres DB.

#### Back Rucio DB

```
docker-compose -f etc/docker/dev/lcls-docker-compose.yml down
docker-compose -f etc/docker/dev/lcls-docker-compose.yml up -d ruciodb
docker exec dev_ruciodb_1 pg_dump -U rucio rucio > /tmp/rucio.bkup.sql # no need to backup DB postgres
```
The first two `docker-compose` commands may be skipped (not tested)

#### Restore Rucio DB

```
docker-compose -f etc/docker/dev/lcls-docker-compose.yml down
docker-compose -f etc/docker/dev/lcls-docker-compose.yml up -d ruciodb
#echo drop database rucio | docker exec dev_ruciodb_1 psql -U rucio postgres
#echo create database rucio | docker exec dev_ruciodb_1 psql -U rucio postgres
echo drop schema dev cascade | docker exec -i dev_ruciodb_1 psql -U rucio rucio
docker exec -i dev_ruciodb_1 psql -U rucio rucio < /tmp/rucio.bkup.sql
docker-compose -f etc/docker/dev/lcls-docker-compose.yml up -d
```

#### Sharing a Rucio DB with multple Rucio instances

Since a Postgres DB can contain multiple Schemas. It is possible (not tested) to use one Rucio DB for multiple 
Rucio instances, with each instance using its own Schema name. The default Schema in the Rucio container is 'dev'. 
For Rucio to use a different Schema name, update:
* 'version_table_schema' in the [alembic] block of /opt/rucio/etc/alembic.ini
* 'schema' in the [database] block of /opt/rucio/etc/rucio.cfg

#### Useful operations directly on DB:

Examples:

##### Dump all PFNs of a RSE

`select scope,name,bytes,state from dev.replicas where rse_id=(select id from dev.rses where rse='GRIDDEV06')`

##### Add adler32 to a file that only has MD5

* `update dev.dids set adler32='f4168743' where md5='bfec14dd0fd2e733df4a7d00511f5a0c';`
* `update dev.replicas set adler32='f4168743' where md5='bfec14dd0fd2e733df4a7d00511f5a0c';`
