## On-boarding rucio

Onboarding instructions are provided here to ease the installation, configuration, and 
usage of rucio targeting a fully working installation for development in the context of a specific project, e.g. LCLS.

For general reference, here's the latest official online documentation: [**Rucio**](https://rucio.cern.ch/documentation/)

### Prerequisites

Install latest [**Docker**](https://docs.docker.com/engine/install/)  and [**docker-compose**](https://docs.docker.com/compose/install/) tools.

### Installation

First, clone the following GitHub repos in a select directory, e.g. rucio-ws:

```
git clone https://github.com/slaclab/rucio.git
git clone https://github.com/slaclab/containers.git
```
These two repos in slaclab were forks from their upstream repos in rucio/rucio and rucio/containers, respectively.
These container images the essential tools installed for Python development, including VI editor.

In the rucio repo, changes were made:
    etc/docker/dev/docker-compose.yml: persists the data catalogs in the configured Postgres backend, 
                                       and integration with fts.

In the containers repo, changes for the project have been made in the following files:
    dev/Dockerfile: updates the repo target  
    dev/rucio.cfg: updates the voname, schema, permission, and support variables 
    dev/rucio.conf: SSL configuration

To build an updated slaclab/rucio image, run this command in containers/dev directory:
```
    docker build -t rucio/rucio-dev .
```
The output of above command is a rucio with tag rucio/rucio-dev:latest, which will be referenced by docker-compose later.

To launch the now ready containers, in rucio/etc/docker/dev:
```
    docker-compose --file docker-compose.yml up -d
```
If successful, three containers will be up and running: 1)dev_rucio_1 (server) 2) dev_rucio_db1 (Postgres) 3) dev_graphite_1 (monitoring).

To stop the rucio containers:
```
    docker-compose --file docker-compose.yml down
```

For related documention, [**Setting up rucio development environment**](https://github.com/slaclab/containers/blob/master/dev/README.rst).

### Set up Schema and Permission Files for Project

The following additions are already in the slaclab/rucio repo.

For defining schema terms referenced in rucio source code, each project should create and update their own version:
    rucio/lib/rucio/common/schema/lcls.py (using atlas. py as template)

In order to enable SSH user authentication, a permission file for the project has to be created:
        rucio/lib/rucio/core/permission/lcls.py (using generic.py as template)

Inside lsls.py, and generic.py as well, notice the critical addition of `get_auth_token_ssh` method:
```
            'reduce_rule': perm_reduce_rule,
            'move_rule': perm_move_rule,
            'get_auth_token_user_pass': perm_get_auth_token_user_pass,
            'get_auth_token_ssh': perm_get_auth_token_ssh,
            'get_auth_token_gss': perm_get_auth_token_gss,
            'get_auth_token_x509': perm_get_auth_token_x509,
            'get_auth_token_saml': perm_get_auth_token_saml,
    
    return False


def perm_get_auth_token_ssh(issuer, kwargs):
    """
    Checks if a user can request a token with ssh for an account.
    :param issuer: Account identifier which issues the command.
    :param kwargs: List of arguments for the action.
    :returns: True if account is allowed, otherwise False
    """
    if kwargs['signature'] is None or kwargs['account'] is None:
        return False
    return True
```

### Configure Database Backend for Data Persistence

For persisting the data in Postgres as database backend, the following section was added in rucio/etc/docker/dev/docker-compose.yml: 
```
ruciodb:
    image: docker.io/postgres:11
    ports:
      - "5432:5432"
    command: ["-c", "fsync=off","-c", "synchronous_commit=off","-c", "full_page_writes=off"]
    volumes:
      - db:/var/lib/postgresql/data
      - /tmp:/tmp

volumes:
  db: {}
```

### Run Unit Tests Provided by rucio 

After installation, enter the rucio container (RUCIOHOME=/opt/rucio):
```
    docker exec -it dev_rucio_1 /bin/bash
```
Then check the rucio server status, by rucio client CLI:
```
    rucio ping
```
which should return the server version.

Check the default user (should return root):
```
    rucio whoami 
```

To run ALL (will take a while) the provided unit tests inside the rucio container to verify the status:
```
    tools/run_tests_docker.sh
```
If any of the tests did not "PASSED", they can be re-run individually for diagnosis using the Python debugger.
For instance, the precise nature of why SSH user authentication was not working in the upstream repo was found out this way.

### External Rucio Client Installation

The client and associated CLI has been installed inside the rucio container.

However, it can also be installed outside, as follows:
```
    pip install rucio-clients
```
See [**Install Rucio Client**](https://rucio.readthedocs.io/en/latest/installing_clients.html).

Then the rest follows the same instructions, e.g. modify rucio.cfg for SSH access, 
as noted in the next section. 

### Create an Admin User with SSH Credentials for Login

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
