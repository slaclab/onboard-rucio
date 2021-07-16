### Interaction with FTS server

FTS services take data transfer requests from Rucio or from users, and manage those data transfers (similar to a batch 
system).
There is an FTS server available. The doc covers Rucio interaction with the FTS services. It does not cover how to 
config/start/stop the FTS services.

The FTS monitoring page is available at https://ruico-dev.slac.stanford.edu:8449/fts3/ftsmon.

For Rucio to use FTS to transfer data, Rucio uses a X509 proxy to authenticate with FTS. This proxy is availe inside 
the Rucio container environment at `/opt/rucio/etc/usercertkey.pem`. Outside of the container, this proxy is located at
`/afs/slac.stanford.edu/g/lcls/rucio/server/x509proxy/x509up_u0`, and is renewed by a TRS cron job.

Before Rucio use this X509 proxy to authenticate with FTS, this proxy needs to be manually delegated to FTS. The
following command needs to be run predically to maintain a valid delegated X509 proxy in FTS:

```
fts-delegation-init -s https://rucio-dev.slac.stanford.edu:8446 -v -j 
    --proxy /afs/slac/g/lcls/rucio/server/x509proxy/x509up_u0 -e 86400  # valid for one day
```
One can run this comamnd from the centrally managed (Client container](./Clients.md). The output of the command 
looks like:
```
{
    "user_cert": "\/afs\/slac.stanford.edu\/g\/lcls\/rucio\/server\/x509proxy\/x509up_u0",
    "user_key": "\/afs\/slac.stanford.edu\/g\/lcls\/rucio\/server\/x509proxy\/x509up_u0",
    "delegation":
    {
        "local_expiration_time": "39:21",
        "message": "No proxy found on server. Requesting standard delegation.",
        "request_duration": "24:0",
        "succeed": true
    }
}

```
