#!/usr/bin/env bash

PWD="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ -z "${BASE_PATH}" ]]; then
  BASE_PATH=$PWD
fi

if [[ -z "${CHAIN}" ]]; then
  CHAIN=mainnet
fi

if [[ -z "${CONSENSUS}" ]]; then
  CONSENSUS=istanbul
fi

if [[ -z "${PRIVACY_IMPL}" ]]; then
  PRIVACY_IMPL=constellation
fi

if [ "${PRIVACY_IMPL}" == "constellation" ]; then
  CONSTELLATION_BIN=$(which constellation-node)
  if [ $? -eq 0 ]
  then
    echo "Constellation starting; bin: ${CONSTELLATION_BIN}"
    
    if [[ -z "${CONSTELLATION_CONFIG}" ]]; then
      CONSTELLATION_CONFIG=constellation.conf
    fi

    if [[ -z "${CONSTELLATION_CONFIG_URL}" ]]; then
      CONSTELLATION_CONFIG_URL="https://raw.githubusercontent.com/providenetwork/node/dev/genesis/defaults/evm/quorum/constellation.conf"
    fi
    curl -L "${CONSTELLATION_CONFIG_URL}" > "${CONSTELLATION_CONFIG}" 2> /dev/nul

    if [ ! -f "${CONSTELLATION_CONFIG}" ] || [ ! -s "${CONSTELLATION_CONFIG}" ]; then
      ${CONSTELLATION_BIN} --port 9001 --url "http://127.0.0.l:9001" &
    else
      ${CONSTELLATION_BIN} "${CONSTELLATION_CONFIG}" &
    fi
  fi
elif [ "${PRIVACY_IMPL}" == "tessera" ]; then
  TESSERA_JAR=/opt/tessera-app.jar
  if [ -f "${TESSERA_JAR}" ]
  then
    TESSERA_BIN="java -jar ${TESSERA_JAR}"
    echo "Tessera starting; bin: ${TESSERA_BIN}"
    
    if [[ -z "${TESSERA_CONFIG}" ]]; then
      TESSERA_CONFIG=constellation.conf
    fi

    if [[ -z "${TESSERA_CONFIG_URL}" ]]; then
      TESSERA_CONFIG_URL="https://raw.githubusercontent.com/providenetwork/node/dev/genesis/defaults/evm/quorum/tessera.json"
    fi
    curl -L "${TESSERA_CONFIG_URL}" > "${TESSERA_CONFIG}" 2> /dev/nul

    if [ ! -f "${TESSERA_CONFIG}" ] || [ ! -s "${TESSERA_CONFIG}" ]; then
      ${TESSERA_BIN} --port 9001 --url "http://127.0.0.l:9001" &
    else
      ${TESSERA_BIN} -configfile "${TESSERA_CONFIG}" &
    fi
  fi
fi

if [[ -z "${CHAIN_SPEC}" ]]; then
  CHAIN_SPEC=spec.json
fi

if [ ! -f "${CHAIN_SPEC}" ] || [ ! -s "${CHAIN_SPEC}" ]; then
  if [[ -z "${CHAIN_SPEC_URL}" ]]; then
    CHAIN_SPEC_URL="https://raw.githubusercontent.com/providenetwork/node/dev/genesis/defaults/evm/quorum/spec.json"
  fi
  curl -L "${CHAIN_SPEC_URL}" > "${CHAIN_SPEC}" 2> /dev/null
  json2toml -o "${CHAIN_SPEC}" "${CHAIN_SPEC}" 2> /dev/null
  cat "${CHAIN_SPEC}"
fi

if [[ -z "${BOOTNODES}" ]]; then
  if [ ! -f bootnodes.txt ] || [ ! -s bootnodes.txt ]; then
    if [[ -z "${BOOTNODES_URL}" ]]; then
      BOOTNODES_URL="https://raw.githubusercontent.com/providenetwork/node/dev/genesis/defaults/evm/quorum/bootnodes.txt"
    fi
    curl -L "${BOOTNODES_URL}" > bootnodes.txt 2> /dev/null
    BOOTNODES=$(cat bootnodes.txt)
  fi
fi

if [[ -z "${LOG_PATH}" ]]; then
  LOG_PATH="${BASE_PATH}/quorum.log"
fi

if [[ -z "${PORT}" ]]; then
  PORT=30300
fi

if [[ -z "${JSON_RPC_INTERFACE}" ]]; then
  JSON_RPC_INTERFACE=0.0.0.0
fi

if [[ -z "${JSON_RPC_PORT}" ]]; then
  JSON_RPC_PORT=8050
fi

if [[ -z "${JSON_RPC_CORS}" ]]; then
  JSON_RPC_CORS=0.0.0.0
fi

if [[ -z "${WS_APIS}" ]]; then
  WS_APIS="web3,eth,pubsub,net,parity,parity_pubsub,traces,rpc,shh,shh_pubsub,quorum,${CONSENSUS}"
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
  JSON_RPC_APIS="db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,${CONSENSUS}"
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

if [[ -z "${SYNC_MODE}" ]]; then
  SYNC_MODE=light
fi

QUORUM_BIN=$(which quorum-geth)
if [ $? -eq 0 ]
then
  echo "provide.network quorum node starting in ${BASE_PATH}; CONSENSUS: ${CONSENSUS}; quorum bin: ${QUORUM_BIN}"

  if [ "${CONSENSUS}" == "istanbul" ]; then
    if [[ -z "${BLOCKTIME}" ]]; then
      BLOCKTIME=5
    fi

    $QUORUM_BIN --config $CHAIN_SPEC \
                --datadir "${BASE_PATH}" \
                --networkid "${NETWORK_ID}" \
                --bootnodes "${BOOTNODES}" \
                --trace "${LOG_PATH}" \
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
                --syncmode "${SYNC_MODE}" \
                --debug \
                --vmdebug \
                --istanbul.blockperiod ${BLOCKTIME} \
                --emitcheckpoints
  elif [ "${CONSENSUS}" == "raft" ]; then
    $QUORUM_BIN --config $CHAIN_SPEC \
                --datadir "${BASE_PATH}" \
                --networkid "${NETWORK_ID}" \
                --bootnodes "${BOOTNODES}" \
                --trace "${LOG_PATH}" \
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
                --syncmode "${SYNC_MODE}" \
                --debug \
                --vmdebug \
                --raft \
                --emitcheckpoints

    # PRIVATE_CONFIG=qdata/c1/tm.ipc nohup geth --datadir qdata/dd1 $ARGS --permissioned --raftport 50401 --rpcport 22000 --port 21000 --unlock 0 --password passwords.txt 2>>qdata/logs/1.log &
    # PRIVATE_CONFIG=qdata/c2/tm.ipc nohup geth --datadir qdata/dd2 $ARGS --permissioned --raftport 50402 --rpcport 22001 --port 21001 --unlock 0 --password passwords.txt 2>>qdata/logs/2.log &
    # PRIVATE_CONFIG=qdata/c3/tm.ipc nohup geth --datadir qdata/dd3 $ARGS --permissioned --raftport 50403 --rpcport 22002 --port 21002 --unlock 0 --password passwords.txt 2>>qdata/logs/3.log &
    # PRIVATE_CONFIG=qdata/c4/tm.ipc nohup geth --datadir qdata/dd4 $ARGS --permissioned --raftport 50404 --rpcport 22003 --port 21003 --unlock 0 --password passwords.txt 2>>qdata/logs/4.log &
    # PRIVATE_CONFIG=qdata/c5/tm.ipc nohup geth --datadir qdata/dd5 $ARGS --raftport 50405 --rpcport 22004 --port 21004 --unlock 0 --password passwords.txt 2>>qdata/logs/5.log &
    # PRIVATE_CONFIG=qdata/c6/tm.ipc nohup geth --datadir qdata/dd6 $ARGS --raftport 50406 --rpcport 22005 --port 21005 --unlock 0 --password passwords.txt 2>>qdata/logs/6.log &
    # PRIVATE_CONFIG=qdata/c7/tm.ipc nohup geth --datadir qdata/dd7 $ARGS --raftport 50407 --rpcport 22006 --port 21006 --unlock 0 --password passwords.txt 2>>qdata/logs/7.log &
  fi
fi
