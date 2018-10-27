#!/usr/bin/env bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${BASE_PATH}" ]]; then
  BASE_PATH=$PWD
fi

CONSTELLATION_BIN=$(which constellation-node)
if [ $? -eq 0 ]
then
  echo "Constellation starting; bin: ${CONSTELLATION_BIN}"
  
  if [[ -z "${CONSTELLATION_CONFIG}" ]]; then
    CONSTELLATION_CONFIG=constellation.conf
  fi

  if [[ -z "${CONSTELLATION_CONFIG_URL}" ]]; then
    CONSTELLATION_CONFIG_URL="https://raw.githubusercontent.com/providenetwork/chain-spec/${CHAIN}/constellation.conf"
  fi
  curl -L "${CONSTELLATION_CONFIG_URL}" > "${CONSTELLATION_CONFIG}" 2> /dev/nul

  ${CONSTELLATION_BIN} "${CONSTELLATION_CONFIG}" &
fi


echo "WARNING: provide.network quorum node not yet supported..."
# echo "provide.network quorum node starting in ${BASE_PATH}; quorum bin: ${QUORUM_BIN}"
