#!/usr/bin/env bash

source ./hnscan.sh

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${BASE_PATH}" ]]; then
  HSD_PREFIX=$PWD
else
  HSD_PREFIX=$BASE_PATH
fi

if [[ -z "${HSD_SPV}" ]]; then
  HSD_SPV=false
fi

HANDSHAKE_BIN=$(which hsd)
if [ $? -ne 0 ]; then
  HANDSHAKE_BIN="${HSD_PREFIX}/bin/hsd"
fi

if [ "$HSD_SPV" = "true" ]; then
  HANDSHAKE_BIN=$(which hnsd)
fi

if [[ -z "${HSD_NETWORK}" ]]; then
  HSD_NETWORK=mainnet
fi

if [[ -z "${HSD_LISTEN}" ]]; then
  HSD_LISTEN=true
fi

if [[ -z "$HSD_BIP37" ]]; then
  HSD_BIP37=false
fi

if [[ -z "$HSD_HOST" ]]; then
  HSD_HOST=0.0.0.0
fi

if [[ -z "$HSD_PORT" ]]; then
  HSD_PORT=5300
fi

if [[ -z "$HSD_PUBLIC_HOST" ]]; then
  HSD_PUBLIC_HOST=0.0.0.0
fi

if [[ -z "$HSD_PUBLIC_PORT" ]]; then
  HSD_PUBLIC_PORT=5300
fi

if [[ -z "$HSD_POOL_SIZE" ]]; then
  HSD_POOL_SIZE=8
fi

if [[ -z "$HSD_MAX_INBOUND" ]]; then
  HSD_MAX_INBOUND=30
fi

if [[ -z "$HSD_MAX_OUTBOUND" ]]; then
  HSD_MAX_OUTBOUND=8
fi

if [[ -z "$HSD_HTTP_HOST" ]]; then
  HSD_HTTP_HOST=0.0.0.0
fi

if [[ -z "$HSD_HTTP_PORT" ]]; then
  if [ "${HSD_NETWORK}" == "mainnet" ]; then
    HSD_HTTP_PORT=12037
  elif [ "${HSD_NETWORK}" == "testnet" ]; then
    HSD_HTTP_PORT=13037
  elif [ "${HSD_NETWORK}" == "regtest" ]; then
    HSD_HTTP_PORT=14037
  elif [ "${HSD_NETWORK}" == "simtest" ]; then
    HSD_HTTP_PORT=15037
  else
    HSD_HTTP_PORT=12037
  fi
fi

if [[ -z "$HSD_CORS" ]]; then
  HSD_CORS=true
fi

if [[ -z "$HSD_INDEX_ADDRESS" ]]; then
  HSD_INDEX_ADDRESS=true
fi

if [[ -z "$HSD_INDEX_TX" ]]; then
  HSD_INDEX_TX=true
fi

echo "option domain_name, host_name" > /etc/dhcpcd.conf
echo "nameserver ${HSD_HOST}" | sudo tee /etc/resolv.conf > /dev/null
setcap 'cap_net_bind_service=+ep' $HANDSHAKE_BIN

if [ "$HSD_SPV" = "false" ]; then
  echo "provide.network handshake (HNS) full node starting in ${PWD}; hsd bin: ${HANDSHAKE_BIN}"
  $HANDSHAKE_BIN --prefix="${HSD_PREFIX}" \
                 --network=${HSD_NETWORK} \
                 --listen=${HSD_LISTEN} \
                 --host=${HSD_HOST} \
                 --port=${HSD_PORT} \
                 --http-host=${HSD_HTTP_HOST} \
                 --http-port=${HSD_HTTP_PORT} \
                 --public-host=${HSD_PUBLIC_HOST} \
                 --public-port=${HSD_PUBLIC_PORT} \
                 --pool-size=${HSD_POOL_SIZE} \
                 --max-outbound=${HSD_MAX_OUTBOUND} \
                 --seeds="${HSD_SEEDS}" \
                 --nodes="${HSD_NODES}" \
                 --bip37=${HSD_BIP37} \
                 --log-level=${LOGGING} \
                 --index-address=${HSD_INDEX_ADDRESS} \
                 --index-tx=${HSD_INDEX_TX} \
                 --api-key="${HSD_API_KEY}" \
                 --cors=${HSD_CORS} \
                 --coinbase-address=${COINBASE}
else
  echo "provide.network handshake (HNS) SPV node starting in ${PWD}; hnsd bin: ${HANDSHAKE_BIN}"
  $HANDSHAKE_BIN --prefix="${HSD_PREFIX}" \
                 --network=${HSD_NETWORK} \
                 --listen=${HSD_LISTEN} \
                 --host=${HSD_HOST} \
                 --port=${HSD_PORT} \
                 --http-host=${HSD_HTTP_HOST} \
                 --http-port=${HSD_HTTP_PORT} \
                 --public-host=${HSD_PUBLIC_HOST} \
                 --public-port=${HSD_PUBLIC_PORT} \
                 --pool-size=${HSD_POOL_SIZE} \
                 --max-outbound=${HSD_MAX_OUTBOUND} \
                 --seeds="${HSD_SEEDS}" \
                 --nodes="${HSD_NODES}" \
                 --bip37=${HSD_BIP37} \
                 --http-host=${HSD_HTTP_HOST} \
                 --log-level=${LOGGING} \
                 --index-address=${HSD_INDEX_ADDRESS} \
                 --index-tx=${HSD_INDEX_TX} \
                 --api-key="${HSD_API_KEY}" \
                 --cors=${HSD_CORS} \
                 --spv
fi
