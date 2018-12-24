#!/usr/bin/env bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${BASE_PATH}" ]]; then
  BCOIN_PREFIX=$PWD
else
  BCOIN_PREFIX=$BASE_PATH
fi

if [[ -z "${BCOIN_SPV}" ]]; then
  BCOIN_SPV=false
fi

BCOIN_BIN=$(which bcoin)
if [ $? -ne 0 ]; then
  BCOIN_BIN="${BCOIN_PREFIX}/bin/bcoin"
fi

if [[ -z "${BCOIN_NETWORK}" ]]; then
  BCOIN_NETWORK=mainnet
fi

if [[ -z "${BCOIN_LISTEN}" ]]; then
  BCOIN_LISTEN=true
fi

if [[ -z "$BCOIN_BIP37" ]]; then
  BCOIN_BIP37=false
fi

if [[ -z "$BCOIN_HOST" ]]; then
  BCOIN_HOST=0.0.0.0
fi

if [[ -z "$BCOIN_PORT" ]]; then
  BCOIN_PORT=5300
fi

if [[ -z "$BCOIN_PUBLIC_HOST" ]]; then
  BCOIN_PUBLIC_HOST=0.0.0.0
fi

if [[ -z "$BCOIN_PUBLIC_PORT" ]]; then
  BCOIN_PUBLIC_PORT=5300
fi

if [[ -z "$BCOIN_POOL_SIZE" ]]; then
  BCOIN_POOL_SIZE=8
fi

if [[ -z "$BCOIN_MAX_INBOUND" ]]; then
  BCOIN_MAX_INBOUND=30
fi

if [[ -z "$BCOIN_MAX_OUTBOUND" ]]; then
  BCOIN_MAX_OUTBOUND=8
fi

if [[ -z "$BCOIN_HTTP_HOST" ]]; then
  BCOIN_HTTP_HOST=0.0.0.0
fi

if [[ -z "$BCOIN_HTTP_PORT" ]]; then
  if [ "${BCOIN_NETWORK}" == "mainnet" ]; then
    BCOIN_HTTP_PORT=8332
  elif [ "${BCOIN_NETWORK}" == "testnet" ]; then
    BCOIN_HTTP_PORT=18332
  elif [ "${BCOIN_NETWORK}" == "regtest" ]; then
    BCOIN_HTTP_PORT=48332
  elif [ "${BCOIN_NETWORK}" == "simtest" ]; then
    BCOIN_HTTP_PORT=18556
  else
    BCOIN_HTTP_PORT=8332
  fi
fi

if [[ -z "$BCOIN_CORS" ]]; then
  BCOIN_CORS=true
fi

if [[ -z "$BCOIN_INDEX_ADDRESS" ]]; then
  BCOIN_INDEX_ADDRESS=true
fi

if [[ -z "$BCOIN_INDEX_TX" ]]; then
  BCOIN_INDEX_TX=true
fi

echo "option domain_name, host_name" > /etc/dhcpcd.conf
echo "nameserver ${BCOIN_HOST}" | sudo tee /etc/resolv.conf > /dev/null
setcap 'cap_net_bind_service=+ep' $BCOIN_BIN

if [ "$BCOIN_SPV" = "false" ]; then
  echo "provide.network bcoin full node starting in ${PWD}; bcoin bin: ${BCOIN_BIN}"
  $BCOIN_BIN --prefix="${BCOIN_PREFIX}" \
             --network=${BCOIN_NETWORK} \
             --listen=${BCOIN_LISTEN} \
             --host=${BCOIN_HOST} \
             --port=${BCOIN_PORT} \
             --http-host=${BCOIN_HTTP_HOST} \
             --http-port=${BCOIN_HTTP_PORT} \
             --public-host=${BCOIN_PUBLIC_HOST} \
             --public-port=${BCOIN_PUBLIC_PORT} \
             --pool-size=${BCOIN_POOL_SIZE} \
             --max-outbound=${BCOIN_MAX_OUTBOUND} \
             --seeds="${BCOIN_SEEDS}" \
             --nodes="${BCOIN_NODES}" \
             --bip37=${BCOIN_BIP37} \
             --log-level=${LOGGING} \
             --index-address=${BCOIN_INDEX_ADDRESS} \
             --index-tx=${BCOIN_INDEX_TX} \
             --api-key=${BCOIN_API_KEY} \
             --cors=${BCOIN_CORS} \
             --coinbase-address=${COINBASE}
else
  echo "provide.network bcoin SPV node starting in ${PWD}; hnsd bin: ${BCOIN_BIN}"
  $BCOIN_BIN --prefix="${BCOIN_PREFIX}" \
             --network=${BCOIN_NETWORK} \
             --listen=${BCOIN_LISTEN} \
             --host=${BCOIN_HOST} \
             --port=${BCOIN_PORT} \
             --http-host=${BCOIN_HTTP_HOST} \
             --http-port=${BCOIN_HTTP_PORT} \
             --public-host=${BCOIN_PUBLIC_HOST} \
             --public-port=${BCOIN_PUBLIC_PORT} \
             --pool-size=${BCOIN_POOL_SIZE} \
             --max-outbound=${BCOIN_MAX_OUTBOUND} \
             --seeds="${BCOIN_SEEDS}" \
             --nodes="${BCOIN_NODES}" \
             --bip37=${BCOIN_BIP37} \
             --http-host=${BCOIN_HTTP_HOST} \
             --log-level=${LOGGING} \
             --index-address=${BCOIN_INDEX_ADDRESS} \
             --index-tx=${BCOIN_INDEX_TX} \
             --api-key=${BCOIN_API_KEY} \
             --cors=${BCOIN_CORS} \
             --spv
fi
