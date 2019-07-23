#!/usr/bin/env bash

if [[ -z "$HNSCAN_PORT" ]]; then
  HNSCAN_PORT=8080
fi

hnscanStartAsync() {
    sleep 10
    echo "provide.network handshake (HNS) blockexplorer (HNScan) starting in ${PWD}/hnscan"
    pushd ./hnscan
    PORT=${HNSCAN_PORT} npm start --production &
    popd
}

hnscanStartAsync &
