# provide.network/node

This is an all-in-one node compatible with blockchains configured with compatibility for the provide.network.

The following EVM clients are made available by 

  - Parity
  - Geth
  - Quorum
  - ewasm

### Dockerfile

Currently, the Dockerfile causes images to be built which contain support for all EVM flavors described above. The `main.sh` entrypoint currently uses the runtime environment to invoke the appropriate all-in-one-packaged client which is compatible with provide.network-configured blockchains.
