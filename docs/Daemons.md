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
When `rucio-reaper` starts, function `__check_rse_usage` in rucio/lib/rucio/daemons/reaper/reaper.py will check 
whether there is a need to free space at specified RSEs, and will not delete from a RSE if there is no space pressure.
(check the reaper.py for algorithm detail)

So for `rucio-reaper` to actually delete something, several daemons has to run
* `rucio-judge-evaluator`: will make sure `lock_cnt` in table replicas decrease. A replica can only be deleted if 
  `lock_cnt` is zero (CHECK: is `rucio-judge-evaluator` responsible to derease `lock_cnt` ?) 
* `rucio-abacus-rse`: this daemon is responsible to update RSE usage
* (optional) `rucio-abacus-account`
* (optional) `rucio-abacus-collection-replica`

After running the above daemons
```
rucio-reaper --run-once --greedy
```



