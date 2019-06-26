#!/usr/bin/env bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${BASE_PATH}" ]]; then
  BASE_PATH=$PWD
fi

if [[ -z "${CHAIN}" ]]; then
  CHAIN=testnet
fi

if [[ -z "${CHAIN_SPEC}" ]]; then
  CHAIN_SPEC=
fi

if [[ -z "${BOOTNODES}" ]]; then
  BOOTNODES=
fi

if [[ -z "${LOG_PATH}" ]]; then
  LOG_PATH="${BASE_PATH}/libra.log"
fi

if [[ -z "${PORT}" ]]; then
  PORT=8000
fi

LIBRA_BIN=$(which libra)
if [ $? -eq 0 ]
then
  echo "provide.network libra node starting in ${BASE_PATH}; libra bin: ${LIBRA_BIN}"
  $LIBRA_BIN
fi
