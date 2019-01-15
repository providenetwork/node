#!/usr/bin/env bash

BURROW_BIN=$(which burrow)
if [ $? -eq 0 ]
then
  echo "Burrow daemon starting; bin: ${BURROW_BIN}"
  ipfs init > /dev/null

  if [[ -z "${BURROW_TOML}" ]]; then
    ${BURROW_BIN} spec -p1 -f1 | ${BURROW_BIN} configure -s- > burrow.toml
  fi

  ${BURROW_BIN} start --validator-index=0
fi
