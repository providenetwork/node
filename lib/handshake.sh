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

if [[ -z "$HSD_SEEDS" ]]; then
  HSD_SEEDS="aoihqqagbhzz6wxg43itefqvmgda4uwtky362p22kbimcyg5fdp54@172.104.214.189,ajdzrpoxsusaw4ixq4ttibxxsuh5fkkduc5qszyboidif2z25i362@173.255.209.126,ajk57wutnhfdzvqwqrgab3wwh4wxoqgnkz4avbln54pgj5jwefcts@172.104.177.177
am2lsmbzzxncaptqjo22jay3mztfwl33bxhkp7icfx7kmi5rvjaic@139.162.183.168"
fi

echo "option domain_name, host_name" > /etc/dhcpcd.conf
echo "nameserver ${HSD_HOST}" | sudo tee /etc/resolv.conf > /dev/null
setcap 'cap_net_bind_service=+ep' $HANDSHAKE_BIN

if [ "$HSD_SPV" = "false" ]; then
  echo "provide.network handshake (HNS) full node starting in ${PWD}; hsd bin: ${HANDSHAKE_BIN}"
  $HANDSHAKE_BIN --prefix="${BASE_PATH}" \
                 --network=${HSD_NETWORK} \
                 --listen=${HSD_LISTEN} \
                 --host=${HSD_HOST} \
                 --port=${HSD_PORT} \
                 --public-host=${HSD_PUBLIC_HOST} \
                 --public-port=${HSD_PUBLIC_PORT} \
                 --pool-size=${HSD_POOL_SIZE} \
                 --max-outbound=${HSD_MAX_OUTBOUND} \
                 --seeds="${HSD_SEEDS}" \
                 --bip37=${HSD_BIP37} \
                 --http-host=${HSD_HTTP_HOST}
else
  echo "provide.network handshake (HNS) SPV resolver daemon starting in ${PWD}; hnsd bin: ${HANDSHAKE_BIN}"
  $HANDSHAKE_BIN
fi
