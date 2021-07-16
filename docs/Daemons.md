### Rucio Daemons

Rucio has many "`daemons`" (commands and processes) that need to be run in order to get things done. These daemons 
(below) exist inside the `rucio/rucio-dev` container.

In a production environment, these daemons are usually be run by cron jobs. Here is a
[list of Rucio daemons](https://rucio.readthedocs.io/en/old-doc/man/daemons.html). It is also possible to run
these damons from cron jobs outside of the Rucio container, as suggested by the 
[Rucio doc](https://rucio.readthedocs.io/en/old-doc/installing_server.html)

The following attempts to list what daemons are needed for common Rucio operations.

#### After adding a data replication rule

At the minimum, the following need to be run every time someone add a Rucio rule to transfer data 
(see `/usr/local/bin/run_daemons`) 
```
rucio-conveyor-submitter --run-once
rucio-conveyor-poller --run-once --older-than 0
rucio-conveyor-finisher --run-once
```

#### Clean up expired replication rules
```
rucio-judge-cleaner --run-once
```

#### Clean up files left by expired replication rules
```
rucio-reaper2 --run-once
```



