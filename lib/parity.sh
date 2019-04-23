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
fi

if [ ! -f "${CHAIN_SPEC}" ] || [ ! -s "${CHAIN_SPEC}" ]; then
  if [[ -z "${CHAIN_SPEC_URL}" ]]; then
    CHAIN_SPEC_URL="https://raw.githubusercontent.com/providenetwork/chain-spec/${CHAIN}/spec.json"
  fi
  curl -L "${CHAIN_SPEC_URL}" > "${CHAIN_SPEC}" 2> /dev/null
fi

if [[ -z "${BOOTNODES}" ]]; then
  if [ ! -f bootnodes.txt ] || [ ! -s bootnodes.txt ]; then
    if [[ -z "${BOOTNODES_URL}" ]]; then
      BOOTNODES_URL="https://raw.githubusercontent.com/providenetwork/chain-spec/${CHAIN}/bootnodes.txt"
    fi
    curl -L "${BOOTNODES_URL}" > bootnodes.txt 2> /dev/null
    BOOTNODES=$(cat bootnodes.txt)
    case $BOOTNODES in  
      *\ * )
        echo "Found invalid characters in bootnodes.txt"
        BOOTNODES=
        ;;
    esac
  fi
fi

if [[ -z "${LOGGING}" ]]; then
  LOGGING=warning
fi

if [[ -z "${LOG_PATH}" ]]; then
  LOG_PATH="${BASE_PATH}/parity.log"
fi

if [[ -z "${ALLOW_IPS}" ]]; then
  ALLOW_IPS=all
fi

if [[ -z "${AUTO_UPDATE}" ]]; then
  AUTO_UPDATE=all
fi

if [[ -z "${RESEAL_ON_TXS}" ]]; then
  RESEAL_ON_TXS=all
fi

if [[ -z "${RESEAL_MAX_PERIOD}" ]]; then
  RESEAL_MAX_PERIOD=120000
fi

if [[ -z "${FAT_DB}" ]]; then
  FAT_DB=on
fi

if [[ -z "${PRUNING}" ]]; then
  PRUNING=archive
fi

if [[ -z "${TRACING}" ]]; then
  TRACING=on
fi

if [[ -z "${PORT}" ]]; then
  PORT=30300
fi

if [[ -z "${PORTS_SHIFT}" ]]; then
  PORTS_SHIFT=0
fi

if [[ -z "${JSON_RPC_INTERFACE}" ]]; then
  JSON_RPC_INTERFACE=all
fi

if [[ -z "${JSON_RPC_PORT}" ]]; then
  JSON_RPC_PORT=8050
fi

if [[ -z "${JSON_RPC_HOSTS}" ]]; then
  JSON_RPC_HOSTS=all
fi

if [[ -z "${JSON_RPC_CORS}" ]]; then
  JSON_RPC_CORS=all
fi

if [[ -z "${JSON_RPC_THREADS}" ]]; then
  JSON_RPC_THREADS=4
fi

if [[ -z "${JSON_RPC_SERVER_THREADS}" ]]; then
  JSON_RPC_SERVER_THREADS=1024
fi

if [[ -z "${IPFS_API_INTERFACE}" ]]; then
  IPFS_API_INTERFACE=0.0.0.0
fi

if [[ -z "${IPFS_API_PORT}" ]]; then
  IPFS_API_PORT=5001
fi

if [[ -z "${IPFS_API_CORS}" ]]; then
  IPFS_API_CORS=all
fi

if [[ -z "${IPFS_API_HOSTS}" ]]; then
  IPFS_API_HOSTS=all
fi

# if [[ -z "${TX_QUEUE_PERSISTENT}" ]]; then
#   TX_QUEUE_PERSISTENT=false
# fi
# --no-persistent-txqueue ${TX_QUEUE_PERSISTENT} \

if [[ -z "${TX_QUEUE_PER_SENDER}" ]]; then
  TX_QUEUE_PER_SENDER=2048
fi

if [[ -z "${WS_APIS}" ]]; then
  WS_APIS=web3,eth,pubsub,net,parity,parity_pubsub,traces,rpc,shh,shh_pubsub
fi

if [[ -z "${WS_PORT}" ]]; then
  WS_PORT=8051
fi

if [[ -z "${WS_MAX_CONNECTIONS}" ]]; then
  WS_MAX_CONNECTIONS=1024
fi

if [[ -z "${WS_INTERFACE}" ]]; then
  WS_INTERFACE=all
fi

if [[ -z "${WS_HOSTS}" ]]; then
  WS_HOSTS=all
fi

if [[ -z "${WS_ORIGINS}" ]]; then
  WS_ORIGINS=all
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

PARITY_BIN=$(which parity)
if [ $? -eq 0 ]
then
  echo "provide.network node starting in ${BASE_PATH}; parity bin: ${PARITY_BIN}"
  $PARITY_BIN --chain $CHAIN_SPEC \
              --base-path "${BASE_PATH}" \
              --bootnodes "${BOOTNODES}" \
              --logging $LOGGING \
              --log-file "${LOG_PATH}" \
              --allow-ips $ALLOW_IPS \
              --auto-update $AUTO_UPDATE \
              --force-sealing \
              --reseal-on-txs $RESEAL_ON_TXS \
              --reseal-max-period $RESEAL_MAX_PERIOD \
              --tx-queue-per-sender ${TX_QUEUE_PER_SENDER} \
              --fat-db $FAT_DB \
              --pruning $PRUNING \
              --tracing $TRACING \
              --port $PORT \
              --ports-shift $PORTS_SHIFT \
              --jsonrpc-apis $JSON_RPC_APIS \
              --jsonrpc-interface $JSON_RPC_INTERFACE \
              --jsonrpc-port $JSON_RPC_PORT \
              --jsonrpc-hosts $JSON_RPC_HOSTS \
              --jsonrpc-cors $JSON_RPC_CORS \
              --jsonrpc-server-threads $JSON_RPC_SERVER_THREADS \
              --jsonrpc-threads $JSON_RPC_THREADS \
              --ws-apis $WS_APIS \
              --ws-port $WS_PORT \
              --ws-interface $WS_INTERFACE \
              --ws-hosts $WS_HOSTS \
              --ws-origins $WS_ORIGINS \
              --ws-max-connections $WS_MAX_CONNECTIONS \
              --engine-signer $ENGINE_SIGNER \
              --password "${ENGINE_SIGNER_KEY_PATH}" \
              --author $COINBASE \
              --identity "${IDENTITY}"
fi
