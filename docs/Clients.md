### External Rucio Client Installation

The client and associated CLI has been installed inside the rucio container.

However, it can also be installed outside, as follows:
```
    pip install rucio-clients
```
Here is an example [rucio.cfg](./rucio.cfg) for SSH access.

See [**Install Rucio Client**](https://rucio.readthedocs.io/en/latest/installing_clients.html).

#### Use a pre-built Rucio client container

There is a Singularity container that has built-in Rucio clients, FTS clients, Gfal2, Xrootd clients and GridFTP clients.
To use it, login to CentOS 7 machine (e.g. centos7.slac.stanford.edu) and run 
```
sh /afs/slac/g/lcls/rucio/clients/singularity/start-rucio-client.sh 
```
Once in the container environment, the default RUCIO_ACCOUNT variable is set to the same as your login name. Please 
change this variable if your RUCIO_ACCOUNT name is something else.

