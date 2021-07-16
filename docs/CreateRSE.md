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
rucio-admin rse set-attribute --rse GRIDDEV06 --key fts --value https://rucio-dev.slac.stanford.edu:8446
rucio-admin rse add-protocol \
  --host griddev06.slac.stanford.edu \
  --scheme root 
  --prefix '//xrootd' 
  --port 1094 \
  --domain-json \
    '{"lan": {"read": 1, "write": 1, "delete": 1}, "wan": {"read": 1, "write": 1, "delete": 1, "third_party_copy": 1}}' 
  GRIDDEV06
```
