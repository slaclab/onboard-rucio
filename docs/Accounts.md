### Create an Account

LCLS rucio will use SSH credentials for user authentication. The following command can be issued from inside the
dev_rucio_1 container, or from an external Rucio client by an authentiction Rucio admin account.

Check to see which accounts already exist, by rucio admin CLI:
```
    rucio-admin account list
```
The key account is root, which is the superuser account, with admin privileges:
```
    rucio-admin account list-attributes root
```
Now let's set up a user account for testing, using SSH authentication.
Run the command: ssh-keygen

The output files will be generated, by default:
```
/root/.ssh/id_rsa        [private key]
/root/.ssh/id_rsa.pub    [public key]
```
Note that root as default account happened to be used here, but can be with any Unix user.

Add the following lines to the rucio configuration (/opt/rucio/etc/rucio.cfg, by default):
```
     [client]
     auth_type=ssh
     ssh_private_key=/root/.ssh/id_rsa
```
The configuration file can be specified using the RUCIO_CONFIG variable, or passing --config CONFIG parameter to the
rucio CLI.  Notice rucio-admin CLI also references rucio.cfg, but not as passing parameter, but can be updated: 
```
    rucio-admin config [-h] {get,set,delete} ...
```

Using the value of the [public key] as id (`cat /root/.ssh/id_rsa.pub`):
```
    rucio-admin account add test-user
    rucio-admin identity add --account test-user --email test-user@lcls.slac.gov --type SSH --id '[public key]'  
```

If this user will have admin privilege
```
    rucio-admin account add-attribute --key admin --value True test-user
```
Now verify the test-user account being set up properly:
```
    rucio-admin account list-attributes test-user
    rucio-admin account list-identities test-user
```

To switch over from default (root) account to the test-user, by setting the RUCIO_ACCOUNT variable:
```
    export RUCIO_ACCOUNT=test-user
    rucio whoami 
```
