#!/usr/bin/env bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${BASE_PATH}" ]]; then
  HSD_PREFIX=$PWD
fi

if [[ -z "${HSD_SPV}" ]]; then
  HSD_SPV=false
fi

HANDSHAKE_BIN=$(which hsd)
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
  HSD_PUBLIC_HOST=$(hostname)
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
  HSD_HTTP_PORT=12039 # default to mainnet
fi

if [[ -z "$HSD_SEEDS" ]]; then
  HSD_SEEDS="aoihqqagbhzz6wxg43itefqvmgda4uwtky362p22kbimcyg5fdp54@172.104.214.189,ajdzrpoxsusaw4ixq4ttibxxsuh5fkkduc5qszyboidif2z25i362@173.255.209.126,ajk57wutnhfdzvqwqrgab3wwh4wxoqgnkz4avbln54pgj5jwefcts@172.104.177.177
am2lsmbzzxncaptqjo22jay3mztfwl33bxhkp7icfx7kmi5rvjaic@139.162.183.168"
fi

if [[ -z "$HSD_API_KEY" ]]; then
  HSD_API_KEY=some-key
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
  $HANDSHAKE_BIN --prefix="${BASE_PATH}" \
                 --network=${HSD_NETWORK} \
                 --listen=${HSD_LISTEN} \
                 --node-host=${HSD_HOST} \
                 --node-port=${HSD_PORT} \
                 --http-host=${HSD_HTTP_HOST} \
                 --http-port=${HSD_HTTP_PORT} \
                 --public-host=${HSD_PUBLIC_HOST} \
                 --public-port=${HSD_PUBLIC_PORT} \
                 --pool-size=${HSD_POOL_SIZE} \
                 --max-outbound=${HSD_MAX_OUTBOUND} \
                 --seeds="${HSD_SEEDS}" \
                 --bip37=${HSD_BIP37} \
                 --http-host=${HSD_HTTP_HOST} \
                 --log-level=${LOGGING} \
                 --index-tx=${HSD_INDEX_TX} \
                 --index-tx=${HSD_INDEX_TX} \
                 --api-key=${HSD_API_KEY} \
                 --cors=${HSD_CORS} \
                 --daemon
else
  echo "provide.network handshake (HNS) SPV node starting in ${PWD}; hnsd bin: ${HANDSHAKE_BIN}"
  $HANDSHAKE_BIN --prefix="${BASE_PATH}" \
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
                 --bip37=${HSD_BIP37} \
                 --http-host=${HSD_HTTP_HOST} \
                 --log-level=${LOGGING} \
                 --index-tx=${HSD_INDEX_TX} \
                 --index-tx=${HSD_INDEX_TX} \
                 --api-key=${HSD_API_KEY} \
                 --cors=${HSD_CORS} \
                 --spv \
                 --daemon
fi
