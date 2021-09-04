### Create RSEs

Creating an RSE will require admin privilege in LCLS.

### Deterministic vs Non-deterministic RSE

For deterministic RSE based on hashes, a function applied to scope:name yields the full path on the RSE.
For instance, the full path of the DID above can be computed to: 
```
        MD5(user.test-user:test.file.1) = 1c8303a0cafc0d1989309c3979d5bcf0
        /1c/83/user.test-user:test.file.1
```
For non-deterministic RSE, the full replica paths must be provided via the list_replicas method.
For the above example based on parent dataset with DID=data:dataset1234:
```
        /data/dataset1234/user.test-user/test.file.1
```       
For reference: [**Typical Replica Workflow**](https://rucio.readthedocs.io/en/latest/replica_workflow.html)

### Base about create RSE

To create a non-deterministic RSE (Note the convention of RSE name: all upper cases):
```
     rucio-admin rse add --non-deterministic TEST-USER_DATADISK
     
```
For a deterministic one:
```
    rucio-admin rse add TEST-USER_DATADISK
```
Now check the default quota (0MB):
``` 
    rucio-admin account get-limits test-user TEST-USER_DATADISK
```
To set a new quota, e.g. 100GB:
```
    rucio-admin account set-limits test-user TEST-USER_DATADISK 100000000000
```
To return information on a RSE:
```
    rucio-admin rse info TEST-USER_DATADISK
```
For reference [**rucio-admin CLI**](https://rucio.readthedocs.io/en/latest/man/rucio-admin.html)

### Example of creating a RSE

The following creates a RSE named GRIDDEV06 (by default deterministic). Its access URL is
`root://griddev06.slac.stanford.edu//xrootd`. When GRIDD06 is a data transfer destination, its transfer is managed 
by FTS server at https://rucio-dev.slac.stanford.edu:8446 (The corresponding monitoring page is 
https://rucio-dev.slac.stanford.edu:8449//fts3/ftsmon)
```
rucio-admin rse add GRIDDEV06
# Do not use: rucio-admin rse set-attribute --rse GRIDDEV06 --key fts --value https://rucio-dev.slac.stanford.edu:8446
rucio-admin rse set-attribute --rse GRIDDEV06 --key fts --value https://134.79.129.252:8446
rucio-admin rse add-protocol \
  --host griddev06.slac.stanford.edu \
  --scheme root \
  --prefix '//xrootd' \
  --port 1094 \
  --domain-json \
    '{"lan":{"read":1, "write":1, "delete":1}, "wan":{"read":1, "write":1, "delete":1, "third_party_copy":1}}' \
  GRIDDEV06
rucio-admin rse add-distance MOCK GRIDDEV06 --distance 1 --ranking 1
rucio-admin rse add-distance GRIDDEV06 MOCK --distance 1 --ranking 1
```
Note:
* doubl slash in '--prefix' path
* `--domain-json` is used and all read/write/... are set to non-zero to avoid exception at https://github.com/rucio/rucio/blob/master/lib/rucio/rse/rsemanager.py#L141 (when uploading)
* The two `rucio-admin rse add-distance` commands are needed, otherwise, rucio-conveyor will not submit data transfer
      from MOCK to GRIDDEV06, and vice verse.
* When adding FTS servers, IP address `134.79.129.252` is used instead of host name `rucio-dev.slac.stanford.edu`. This
is because we are running Rucio and FTS services in Docker containers, all on `rucio-dev.slac.stanford.edu`. Most of these
contained are NAT-ed yet all of them use hostname `rucio-dev.slac.stanford.edu` inside the container (in order to use the
InCommon IGTF host certificate). So for the Rucio
container to reach the FTS container on the same host, the Rucio container has to use the IP address.

### How to delete a RSE

Let's try to delete RSE XRD1. Command `rucio-admin rse delete XRD1` will only DISABLE this RSE (equivalent to 
`update dev.rses set deleted='t' where rse='XRD1';`). After this command, the RSE is not visible via the Rucio
commands. But it is still there in DB.

Using this SQL command `update dev.rses set deleted='f' where rse='XRD1';` will make it visible again. Note for this SQL
and all SQLs below: when DB alembic_verion is updated, some of the SQLs will not work. This is an disadvantage
of using SQL.

To list what is in a RSE, do
* `select * from dev.replicas where rse_id = (select id from dev.rses where rse='XRD1');`
* apple the same to table `dev.quarantined_replicas`, `dev.bad_replicas` and `dev.*_history`.

To actually DELETE a RSE, do 
* clean/delete replicas from the RSE
* `rucio-admin rse info XRD1` to see all protocols and attributes of the RSE, and use 
`rucio-admin rse delete-protocol ...` and `rucio-admin rse delete-attribute ...` to delete all of them, or use SQL:
   * `delete from dev.rse_protocols where rse_id = (select id from dev.rses where rse='XRD1');`
   * `delete from dev.rse_attr_map  where rse_id = (select id from dev.rses where rse='XRD1');`
* (maybe needed), run `rucio-abacus-rse --run-once`
* (maybe needed), run `rucio-abacus-account --run-once` 
* `rucio-admin rse delete XRD1` or `update dev.rses set deleted='t' where rse='XRD1';`
* `delete from dev.account_usage where rse_id=(select id from dev.rses where rse='XRD1');`
* `delete from dev.rse_usage where rse_id=(select id from dev.rses where rse='XRD1');`
* `delete from dev.rses where rse='XRD1';`

The complexity of the above shows that deleting a RSE isn't always a good idea. It is difficutl to completely delete 
all references to a RSE in the Rucio DB. Unless there is a need, it is better to just disable a RSE.

