#!/usr/bin/env bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${BASE_PATH}" ]]; then
  BASE_PATH=$PWD
fi

if [[ -z "${CHAIN}" ]]; then
  CHAIN=master
fi

if [[ -z "${CHAIN_SPEC}" ]]; then
  CHAIN_SPEC=${BASE_PATH}/ewasm-spec.json

  if [ ! -f "${CHAIN_SPEC}" ] || [ ! -s "${CHAIN_SPEC}" ]; then
    if [[ -z "${CHAIN_SPEC_URL}" ]]; then
      CHAIN_SPEC_URL="https://raw.githubusercontent.com/ewasm/testnet/${CHAIN}/ewasm-testnet-cpp-config.json"
    fi
    curl "${CHAIN_SPEC_URL}" > "${CHAIN_SPEC}" 2> /dev/null
  fi
fi

if [[ -z "${PEER_SET}" ]]; then
  if [ ! -f enodes.txt ] || [ ! -s enodes.txt ]; then
    if [[ ! -z "${BOOTNODES_URL}" ]]; then
      curl "${BOOTNODES_URL}" > enodes.txt 2> /dev/null
      PEER_SET=$(cat enodes.txt | sed 's/,/ /g')
    fi
  fi
fi

if [[ -z "${DB_PATH}" ]]; then
  DB_PATH=${BASE_PATH}/${CHAIN}
fi

if [[ -z "${EVMC_FALLBACK}" ]]; then
  EVMC_FALLBACK=true
fi

if [[ -z "${ASK}" ]]; then
  ASK=0
fi

if [[ -z "${BID}" ]]; then
  BID=20000000000
fi

if [[ -z "${COINBASE}" ]]; then
  COINBASE=0x0000000000000000000000000000000000000000
fi

if [[ -z "${IPC_PATH}" ]]; then
  IPC_PATH=${DB_PATH}/geth.ipc
fi

if [[ -z "${JSON_RPC_PORT}" ]]; then
  JSON_RPC_PORT=8050
fi

if [[ -z "${JSON_RPC_PROXY_PY}" ]]; then
  JSON_RPC_PROXY_PY=/usr/local/bin/jsonrpcproxy.py
fi

if [[ -z "${JSON_RPC_PROXY_URL}" ]]; then
  JSON_RPC_PROXY_URL=http://0.0.0.0:${JSON_RPC_PORT}
fi

if [[ -z "${LISTEN_IP}" ]]; then
  LISTEN_IP=0.0.0.0
fi

if [[ -z "${LISTEN_PORT}" ]]; then
  LISTEN_PORT=30303
fi

if [[ -z "${LOG_VERBOSITY}" ]]; then
  LOG_VERBOSITY=2
fi

if [[ -z "${LOG_PATH}" ]]; then
  LOG_PATH="${BASE_PATH}/cpp-ethereum.log"
fi

if [[ -z "${MINING}" ]]; then
  MINING=on
fi

if [[ -z "${MINING_THREADS}" ]]; then
  MINING_THREADS=1
fi

if [[ -z "${NETWORK_ID}" ]]; then
  NETWORK_ID=66
fi

if [[ -z "${MODE}" ]]; then
  MODE=full
fi

if [[ -z "${PORT}" ]]; then
  PORT=30303
fi

if [[ -z "${PUBLIC_IP}" ]]; then
  PUBLIC_IP=$(curl -s https://api.ipify.org 2> /dev/null)
fi

if [[ -z "${VM}" ]]; then
  VM=/usr/local/lib/libhera.so
fi

CPP_ETH_BIN=$(which aleth)
if [ $? -eq 0 ]; then
  echo "ewasm testnet node starting in ${BASE_PATH}; cpp-ethereum bin: ${CPP_ETH_BIN}"
fi

$CPP_ETH_BIN --address ${COINBASE} \
             --ask ${ASK} \
             --bid ${BID} \
             --config ${CHAIN_SPEC} \
             --db-path ${DB_PATH} \
             --evmc fallback=${EVMC_FALLBACK} \
             --listen-ip ${LISTEN_IP} \
             --listen ${LISTEN_PORT} \
             --log-verbosity ${LOG_VERBOSITY} \
             --mining ${MINING} \
             --mining-threads ${MINING_THREADS} \
             --mode ${MODE} \
             --network-id ${NETWORK_ID} \
             --no-bootstrap \
             ${PEER_SET:+ --peerset "${PEER_SET}"} \
             --port ${PORT} \
             --public-ip ${PUBLIC_IP} \
             --vm ${VM} &

while [[ -z "${nodeInfo}" ]]; do
  resp=$(echo '{"jsonrpc": "2.0", "method": "admin_nodeInfo", "params": [], "id": null}' | nc -U "${IPC_PATH}" 2> /dev/null)
  if [ $? -eq 0 ]; then
    nodeInfo=$(echo "${resp}" | sed s/\:0\"/\:${LISTEN_PORT}\"/g)
  fi
done
echo "${nodeInfo}"

echo "Running ${JSON_RPC_PROXY_PY}; IPC path: ${IPC_PATH}; JSON-RPC proxy: ${JSON_RPC_PROXY_URL}"
python3 "${JSON_RPC_PROXY_PY}" "${IPC_PATH}" "${JSON_RPC_PROXY_URL}"
