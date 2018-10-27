#!/usr/bin/env bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${BASE_PATH}" ]]; then
  BASE_PATH=$PWD
fi

if [[ -z "${CHAIN}" ]]; then
  CHAIN=mainnet
fi

if [[ -z "${CHAIN_SPEC}" ]]; then
  CHAIN_SPEC=spec.json

  if [ ! -f "${CHAIN_SPEC}" ] || [ ! -s "${CHAIN_SPEC}" ]; then
    if [[ -z "${CHAIN_SPEC_URL}" ]]; then
      CHAIN_SPEC_URL="https://raw.githubusercontent.com/providenetwork/chain-spec/${CHAIN}/spec.json"
    fi
    curl -L "${CHAIN_SPEC_URL}" > "${CHAIN_SPEC}" 2> /dev/null
  fi
fi

if [[ -z "${BOOTNODES}" ]]; then
  if [ ! -f bootnodes.txt ] || [ ! -s bootnodes.txt ]; then
    if [[ -z "${BOOTNODES_URL}" ]]; then
      BOOTNODES_URL="https://raw.githubusercontent.com/providenetwork/chain-spec/${CHAIN}/bootnodes.txt"
    fi
    curl -L "${BOOTNODES_URL}" > bootnodes.txt 2> /dev/null
    BOOTNODES=$(cat bootnodes.txt)
  fi
fi

if [[ -z "${LOG_PATH}" ]]; then
  LOG_PATH="${BASE_PATH}/parity.log"
fi

if [[ -z "${PORT}" ]]; then
  PORT=30300
fi

if [[ -z "${JSON_RPC_PORT}" ]]; then
  JSON_RPC_PORT=8050
fi

if [[ -z "${JSON_RPC_CORS}" ]]; then
  JSON_RPC_CORS=0.0.0.0
fi

if [[ -z "${WS_APIS}" ]]; then
  WS_APIS=web3,eth,pubsub,net,parity,parity_pubsub,traces,rpc,shh,shh_pubsub
fi

if [[ -z "${WS_PORT}" ]]; then
  WS_PORT=8051
fi

if [[ -z "${WS_INTERFACE}" ]]; then
  WS_INTERFACE=0.0.0.0
fi

if [[ -z "${WS_ORIGINS}" ]]; then
  WS_ORIGINS=0.0.0.0
fi

if [[ -z "${JSON_RPC_APIS}" ]]; then
  JSON_RPC_APIS=web3,eth,net,personal,parity,parity_set,traces,rpc,parity_accounts
fi

if [[ -z "${ENGINE_SIGNER}" ]]; then
  ENGINE_SIGNER=0x0000000000000000000000000000000000000000
fi

if [[ -z "${ENGINE_SIGNER_KEY_PATH}" ]]; then
  ENGINE_SIGNER_KEY_PATH="${BASE_PATH}/.${ENGINE_SIGNER}.key"
fi

if [ ! -f "${ENGINE_SIGNER_KEY_PATH}" ]; then
  touch "${ENGINE_SIGNER_KEY_PATH}"

  if [[ ! -z "${ENGINE_SIGNER_PRIVATE_KEY}" ]]; then
    echo "${ENGINE_SIGNER_PRIVATE_KEY}" > $ENGINE_SIGNER_KEY_PATH
  fi

  if [[ ! -z "${ENGINE_SIGNER_KEY_JSON}" ]]; then
    mkdir -p "${BASE_PATH}/keys"
    echo "${ENGINE_SIGNER_KEY_JSON}" > "${BASE_PATH}/keys/${ENGINE_SIGNER}.json"
    chmod 0600 "${BASE_PATH}/keys/${ENGINE_SIGNER}.json"
  fi
fi
chmod 0600 "${ENGINE_SIGNER_KEY_PATH}"

if [[ -z "${COINBASE}" ]]; then
  COINBASE=$ENGINE_SIGNER
fi

if [[ -z "${IDENTITY}" ]]; then
  IDENTITY=
fi

if [[ -z "${GC_MODE}" ]]; then
  GC_MODE=archive
fi

if [[ -z "${SYNC_MODE}" ]]; then
  SYNC_MODE=light
fi

GETH_BIN=$(which geth)
if [ $? -eq 0 ]
then
  echo "provide.network node starting in ${BASE_PATH}; geth bin: ${GETH_BIN}"
  $GETH_BIN --config $CHAIN_SPEC \
              --datadir "${BASE_PATH}" \
              --networkid "${CHAIN}" \
              --bootnodes "${BOOTNODES}" \
              --trace "${LOG_PATH}" \
              --gcmode "${GC_MODE}" \
              --port $PORT \
              --rpc \
              --rpcapi $JSON_RPC_APIS \
              --rpcaddr $JSON_RPC_INTERFACE \
              --rpcport $JSON_RPC_PORT \
              --rpccorsdomain $JSON_RPC_CORS \
              --ws \
              --wsapi $WS_APIS \
              --wsaddr $WS_INTERFACE \
              --wsport $WS_PORT \
              --wsorigins $WS_ORIGINS \
              --password "${ENGINE_SIGNER_KEY_PATH}" \
              --etherbase $COINBASE \
              --identity "${IDENTITY}" \
              --syncmode "${SYNCMODE}" \
              --debug \
              --vmdebug
fi
