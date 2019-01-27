#!/usr/bin/env bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${IMPL}" ]]; then
  IMPL=burrow # likely to default to fabric once fabric support is complete
fi

if [[ -z "${BASE_PATH}" ]]; then
  BASE_PATH=$PWD
fi

if [ "${IMPL}" == "burrow" ]; then
  BURROW_BIN=$(which burrow)
  if [ $? -eq 0 ]
  then
    if [[ -z "${BURROW_TOML}" ]]; then
      echo "WARNING: using default hyperledger burrow configuration since no toml source was provided; ${BURROW_BIN}"
      ${BURROW_BIN} spec -p1 -f1 | ${BURROW_BIN} configure -s- > burrow.toml
    fi

    echo "provide.network hyperledger burrow node starting in ${PWD}; burrow bin: ${BURROW_BIN}"
    ${BURROW_BIN} start --validator-index=0
  fi
elif [ "${IMPL}" == "fabric" ]; then
  echo "WARNING: provide.network hyperledger fabric node cannot starting in ${PWD}; fabric not yet implemented"
fi
