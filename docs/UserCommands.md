### Rucio commands for users

#### Data Identifiers (DID), Rucio Storage Element (RSE), and Scopes

To query existing RSEs and Scopes:
```
    rucio list-rses
    rucio list-scopes
```
#### To add a new scope:
```
    rucio-admin scope add --account test-user --scope user.test-user
```
In rucio, a DID has the following format:
        scope:name , e.g. user.test-user:test.file.1

Note: (under ATLAS policy) an ordinary user can only own scope user.$RUCIO_ACCOUNT. An admin user can create any
scope.

#### Upload a file/DID to Rucio and a RSE

An example of uploading a local file to `GRIDDEV06` (a RSE) as DID `user.$RUCIO_ACCOUNT:junk1`
```
    rucio -v upload --rse GRIDDEV06 --scope user.$RUCIO_ACCOUNT --name junk1 local_file
```
This command will first create the DID in Rucio, then use a data transfer protocol (gridftp, root, https, etc.) offered
by the RSE to upload the file. If the upload fails, the command can be run again after issue is fixed.

Given that this command does not specify a PFN (physical file name/path in the RSE), the PFN will be determined according
to the lfn2pfn algorithm defined in the RSE.

#### Register a file/DID to Rucio without upload

It is also possible to register a DID with Rucio without uploading the file. The scenario is that the file has already 
been uploaded by other means, and prossibly the actual PFN does not follow the lfn2pfn algorithm of the RSE.
The command to register a DID only is:
```
    rucio -v upload --rse RSE --scope user.$RUCIO_ACCOUNT --name junk1 --pfn path_on_storage --register-after-upload
```
(please check, not sure about the above command)

#### Check the uploaded file

A few useful commands to check the just uploaded file/DID
```
   rucio list-file-replicas user.$RUCIO_ACCOUNT:junk1
   rucio list-rules user.$RUCIO_ACCOUNT:junk1
```
Suppose the second command return Rucio `rule_id` `4b8f63659f564791913951dbcfc70c9b`, then the following will return
more info about this Rucio rule
```
   rucio rule-info 4b8f63659f564791913951dbcfc70c9b
```

#### Replicate a file to a RSE

* Use the `rucio add-rule` command. Rucio will choose a source RSE, unless user specified the source RSE. The command
will return a ruico rule_id (a long string).
* Use the `rucio rule-info rule_id` command to check the status of replication.

