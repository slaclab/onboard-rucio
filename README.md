## On-boarding rucio

Onboarding instructions are provided here to ease the installation, configuration, and 
usage of rucio targeting a fully working installation for development in the context of a specific project, e.g. LCLS.

For general reference, here's the latest official online documentation: [**Rucio**](https://rucio.cern.ch/documentation/)

### Installation

The [Installation doc](./docs/Installation.md) describes how to install, how to do initial bootstripe and unit test.
accounts.

### Add Acccounts

The [Accounts doc](./docs/Accounts.md) describes how to add an Rucio account, including accounts with admin privilege.

### External Rucio Client Installation

The [Clients doc](./docs/Clients.md) has info about installing your own Rucio client, or using a centrally managed client
in a Singularity container.

### Create RSEs

The [Create RSE doc](./docs/CreateDeleteRSE.md) gives an example of how to create a RSE, and how to completely delete a RSE
(as oppose to just disable a RSE)

### Interact with FTS service

The [Interaction with FTS doc](./docs/InteractWithFTS.md) describes requirement of manually delegating a X509 proxy to
the FTS servers. And info about FTS server monitoring.

### Backup, Restore and Sharing Rucio Postgres DB

The [Backup and Restore Rucio DB](./docs/DBbackupNrestore.md) gives basic, invasive mechanism for backup and restore
of the Rucio Postgres DB, as well as a (not the best) mechanism to share Rucio DB for multiple Rucio instances.

### Basic Rucio operation and daemons

The [Rucio daemons](./docs/Daemons.md) gives info about what daemons need to be run after a Rucio rule is added, when a DID expireds, etc.

### User commands

The [User commands doc](./docs/UserCommands.md) serve as a FAQ about how to interact with Rucio as a user.
