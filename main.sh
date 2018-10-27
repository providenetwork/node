#!/usr/bin/env bash

if [[ -z "${CLIENT}" ]]; then
  CLIENT=parity
fi

if [[ -z "${IPFS_DAEMON}" ]]; then
  IPFS_DAEMON=true
fi

if [ "$IPFS_DAEMON" = "true" ]; then
  source ./ipfs.sh
fi

if [ "$CLIENT" = "geth" ]; then
  source ./geth.sh
elif [ "$CLIENT" = "parity" ]; then
  source ./parity.sh
elif [ "$CLIENT" = "ewasm-cpp-eth" ]; then
  source ./ewasm-cpp-eth.sh
elif [ "$CLIENT" = "quorum" ]; then
  source ./quorum.sh
fi
