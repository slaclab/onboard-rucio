## On-boarding rucio

Onboarding instructions are provided here to ease the installation, configuration, and 
usage of rucio targeting a fully working installation for development in the context of a specific project, e.g. LCLS.

For general reference, here's the latest official online documentation: [**Rucio**](https://rucio.cern.ch/documentation/)

### Installation

The [Installation doc](./docs/Installation.md) describes how to install, how to do initial bootstripe and unit test.
accounts.

### Adding Acccounts

The [Accounts doc](./docs/Accounts.md) describes how to add an Rucio account, including accounts with admin privilege.

### External Rucio Client Installation

The [Clients doc](./docs/Clients.md) has info about installing your own Rucio client, or using a centrally managed client
in a Singularity container.

### Create RSEs

To create a non-deterministic RSE:
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

### Interfacing with fts service

The fts service is pre-configured in docker-compose.yml in the rucio repo.

### Data Identifiers (DID), Rucio Storage Element (RSE), and Scopes

To query existing RSEs and Scopes:
```
    rucio list-rses
    rucio list-scopes
```
To add a new scope:
```
    rucio-admin scope add --account test-user --scope user.test-user
```
In rucio, a DID has the following format:
        scope:name , e.g. user.test-user:test.file.1

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
