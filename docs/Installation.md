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
If successful, three containers will be up and running: 1)dev_rucio_1 (server) 2) dev_rucio_db1 (Postgres) 3) dev_graphite_1 (monitoring). Here is an example [docker-compose.yml for lcls](./lcls-docker-compose.yml).

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
