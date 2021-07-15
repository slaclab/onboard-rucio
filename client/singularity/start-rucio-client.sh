#!/bin/sh

unset PYTHONPATH
mydir=$(dirname $(readlink -f $0))
singularity shell -B /afs/slac/package/vdt/vol7/certificates:/etc/grid-security/certificates \
                  -B /afs/slac/package/vdt/vol7/vomsdir:/etc/grid-security/vomsdir \
                  -B /afs/slac/package/vdt/vol7/vomses:/etc/vomses \
                  -B /afs,/nfs,/u,/gpfs,/cvmfs \
                  -B ${mydir}/gfal.py:/usr/local/lib/python3.6/site-packages/rucio/rse/protocols/gfal.py \
                  $mydir/rucio-client.sif
