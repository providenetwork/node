#!/usr/bin/env bash
echo "Starting client: "${CLIENT}

if [[ -z "${CLIENT}" ]]; then
  CLIENT=quorum
  if [[ -z "${CONSENSUS}" ]]; then
    CONSENSUS=instanbul
  fi
fi

if [[ -z "${IPFS_DAEMON}" ]]; then
  IPFS_DAEMON=true
fi

if [ "$IPFS_DAEMON" = "true" ]; then
  source ./ipfs.sh
fi

if [ "$CLIENT" = "bcoin" ]; then
  source ./bcoin.sh
elif [ "$CLIENT" = "geth" ]; then
  source ./geth.sh
elif [ "$CLIENT" = "parity" ]; then
  source ./parity.sh
elif [ "$CLIENT" = "parity-aura-pos" ]; then
  source ./parity-aura-pos.sh
elif [ "$CLIENT" = "ewasm-cpp-eth" ]; then
  source ./ewasm-cpp-eth.sh
elif [ "$CLIENT" = "handshake" ]; then
  source ./handshake.sh
elif [ "$CLIENT" = "hyperledger" ]; then
  source ./hyperledger.sh
elif [ "$CLIENT" = "libra" ]; then
  source ./libra.sh
elif [ "$CLIENT" = "quorum" ]; then
  source ./quorum.sh
fi
