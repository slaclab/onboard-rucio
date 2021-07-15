export TERM=linux
export RUCIO_ACCOUNT=$(id -un)
export RUCIO_CONFIG=/afs/slac/g/lcls/rucio/clients/singularity/rucio-client.cfg
export X509_USER_PROXY=$HOME/x509up_u$(id -u)

export XrdSecSSSKT=/afs/slac/g/lcls/rucio/clients/singularity/sss.keytab
