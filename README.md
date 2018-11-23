# provide.network/node

This is an all-in-one node that is compatible with select blockchain protocols and blockexplorers which can be configured using a semi-uniform set of configuration options provide.network.

## EVM Support

The following EVM-based clients and protocols are currently supported (in no particular order):

  - [Parity](https://wiki.parity.io/Parity-Ethereum) - [Authority Round PoA](https://wiki.parity.io/Aura); a highly-upgradeable Aura implementation lives in [this repo](https://github.com/providenetwork/network-consensus-contracts); ~~PoW~~ supported (`parity.sh`)
  - [Geth](https://github.com/ethereum/go-ethereum/wiki/geth) vanilla Clique PoA & PoW supported (`geth.sh`)
  - [Quorum](https://github.com/jpmorganchase/quorum) - [IBFT](https://github.com/ethereum/EIPs/issues/650) with [Constellation](https://github.com/jpmorganchase/constellation); ~~[Raft](https://raft.github.io)~~ (`quorum.sh`)
  - [ewasm](https://github.com/ewasm/design) - [ewasm testnet PR #50](https://github.com/ewasm/testnet/pull/50)

## Bcoin Support

The following [Bcoin](https://bcoin.io) protocols are supported:

  - [Handshake](https://handshake-org.github.io)

## IPFS Support

By default, regardless of the client/protocol implementation targeted for execution, the container starts a local IPFS daemon which should be added to a load-balanced IPFS network. Environment support for configuring the IPFS daemon to connect to a private network; documentation forthcoming.

### Dockerfile

Currently, the Dockerfile builds a very fat image which contains all supported clients and protocols. The reason for this is simply for the sake of convenience when [provide.network](https://provide.network) nodes are being launched via the [Provide PaaS](https://provide.services). It will make sense in the near future to further parameterize `docker build` invocations such that only the desired functionality is built to expedite build times and bandwidth (i.e., when the resulting container is being shipped over the network).

The `main.sh` entrypoint uses environment variables supplied at container runtime to invoke the appropriate client binary (or binaries in the case of permissioned networks such as Quorum).
