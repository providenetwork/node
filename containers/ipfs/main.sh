#!/usr/bin/env bash

IPFS_BIN=$(which ipfs)
if [ $? -eq 0 ]
then
  echo "IPFS daemon starting; bin: ${IPFS_BIN}"
  ipfs init > /dev/null

  if [[ -z "${IPFS_API_PORT}" ]]; then
    IPFS_API_PORT=5001
  fi

  if [[ -z "${IPFS_GATEWAY_PORT}" ]]; then
    IPFS_GATEWAY_PORT=8080
  fi

  if [[ -z "${IPFS_CORS_ORIGINS}" ]]; then
    IPFS_CORS_ORIGINS='["*"]'
  fi

  if [[ -z "${IPFS_CORS_METHODS}" ]]; then
    IPFS_CORS_METHODS='["GET", "POST", "PUT", "DELETE", "OPTIONS"]'
  fi

  ipfs config Addresses.API /ip4/0.0.0.0/tcp/${IPFS_API_PORT}
  ipfs config Addresses.Gateway /ip4/0.0.0.0/tcp/${IPFS_GATEWAY_PORT}
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin ${IPFS_CORS_ORIGINS}
  ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods ${IPFS_CORS_METHODS}

  if [ "$CLIENT" = "ipfs" ]; then
    ipfs daemon
  else
    ipfs daemon &
  fi
fi
