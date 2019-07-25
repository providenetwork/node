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

echo "check if CHAIN_SPEC exists"
if [ ! -f "${CHAIN_SPEC}" ] || [ ! -s "${CHAIN_SPEC}" ]; then
  echo "check CHAIN_SPEC_URL"
  echo "${CHAIN_SPEC_URL}"
  if [[ -z "${CHAIN_SPEC_URL}" ]]; then
    CHAIN_SPEC_URL="https://raw.githubusercontent.com/providenetwork/node/dev/genesis/defaults/evm/quorum/spec.json"
  fi
  echo "get CHAIN_SPEC_URL to file"
  curl -L "${CHAIN_SPEC_URL}" > "${CHAIN_SPEC}" #2> /dev/null
  # echo "convert CHAIN_SPEC"
  # json2toml -o "${CHAIN_SPEC}" "spec.toml" #2> /dev/null
  echo "output CHAIN_SPEC"
  cat "${CHAIN_SPEC}"
  # echo "output TOML"
  # cat "spec.toml"
fi

# if [[ -z "${BOOTNODES}" ]]; then
#   if [ ! -f bootnodes.txt ] || [ ! -s bootnodes.txt ]; then
#     if [[ -z "${BOOTNODES_URL}" ]]; then
#       BOOTNODES_URL="https://raw.githubusercontent.com/providenetwork/node/dev/genesis/defaults/evm/quorum/bootnodes.txt"
#     fi
#     curl -L "${BOOTNODES_URL}" > bootnodes.txt 2> /dev/null
#     BOOTNODES=$(cat bootnodes.txt)
#   fi
# fi

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
  WS_APIS="web3,eth,pubsub,net,traces,rpc,shh,shh_pubsub,quorum,${CONSENSUS}"
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
  COINBASE="0x$ENGINE_SIGNER"
fi

if [[ -z "${IDENTITY}" ]]; then
  IDENTITY=
fi

if [[ -z "${SYNC_MODE}" ]]; then
  SYNC_MODE=light
fi

QUORUM_BIN=$(which quorum-geth)
QUORUM_BOOTNODE_BIN=$(which quorum-bootnode)
if [ $? -eq 0 ]
then
  echo "provide.network quorum node starting in ${BASE_PATH}; CONSENSUS: ${CONSENSUS}; quorum bin: ${QUORUM_BIN}"

  if [ "${CONSENSUS}" == "istanbul" ]; then
    if [[ -z "${BLOCKTIME}" ]]; then
      BLOCKTIME=5
    fi

    CONFIG_TOML="${BASE_PATH}/config.toml"
    $QUORUM_BIN --datadir "${BASE_PATH}/quorum-node-1" --networkid "${NETWORK_ID}" \
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
                --emitcheckpoints dumpconfig > $CONFIG_TOML
                    
    echo "Starting network with config"
    cat $CONFIG_TOML

    if [[ -z "${BOOTNODES}" ]]; then
      PRIVATE_CONFIG=ignore nohup $QUORUM_BIN --config $CONFIG_TOML \
                  --istanbul.blockperiod ${BLOCKTIME} >> node.log 2>&1 &
    else
      PRIVATE_CONFIG=ignore nohup $QUORUM_BIN --config $CONFIG_TOML \
                  --bootnodes "${BOOTNODES}" \
                  --istanbul.blockperiod ${BLOCKTIME} >> node.log 2>&1 &
    fi

  elif [ "${CONSENSUS}" == "raft" ]; then
    mkdir quorum-node-1
    mkdir quorum-node-1/keystore
    curl -L "${ENGINE_SIGNER_KEY_URL}" > "quorum-node-1/keystore/UTC--${ENGINE_SIGNER_UTC}--${ENGINE_SIGNER}" 2> /dev/null

    # password1=quorum-node-1/password
    # echo "verySTRONGpassword1" > quorum-node-1/password
    # $QUORUM_BIN --datadir quorum-node-1 account new --password "${BASE_PATH}/quorum-node-1/password"
    # $QUORUM_BIN --datadir quorum-node-1 account new --password <(echo $mypassword)

    $QUORUM_BIN account list --keystore "quorum-node-1/keystore"
    # $QUORUM_BIN account import "${BASE_PATH}/keys/UTC--${ENGINE_SIGNER_UTC}--${ENGINE_SIGNER}"

    echo $BASE_PATH
    # ls "${BASE_PATH}"
    ls "${BASE_PATH}/quorum-node-1/keystore"
    # ls "${BASE_PATH}/keys"

    for f in "${BASE_PATH}/quorum-node-1/keystore/*"
    do 
      cat $f
    done

    $QUORUM_BOOTNODE_BIN --genkey=nodekey
    cp nodekey quorum-node-1/
    
    $QUORUM_BOOTNODE_BIN --nodekey=quorum-node-1/nodekey --writeaddress > quorum-node-1/enode
    ENODE1=$(cat quorum-node-1/enode)
    echo "[\"enode://${ENODE1}@127.0.0.1:21000?discport=0&raftport=50000\"]" > quorum-node-1/static-nodes.json
    echo "bootnodes:"
    cat quorum-node-1/static-nodes.json
    # BOOTNODES=$(cat quorum-node-1/static-nodes.json)

    echo ${CHAIN_SPEC}
    cat ${CHAIN_SPEC}

    $QUORUM_BIN --datadir quorum-node-1 init ${CHAIN_SPEC}
    
    CONFIG_TOML="${BASE_PATH}/config.toml"
    $QUORUM_BIN --datadir "${BASE_PATH}/quorum-node-1" --networkid "${NETWORK_ID}" \
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
                --emitcheckpoints dumpconfig > $CONFIG_TOML

    echo "Starting network with config"
    cat $CONFIG_TOML
         
    if [[ -z "${BOOTNODES}" ]]; then
      PRIVATE_CONFIG=ignore nohup $QUORUM_BIN --config $CONFIG_TOML \
                  --raft >> node.log 2>&1 &
    else
      PRIVATE_CONFIG=ignore nohup $QUORUM_BIN --config $CONFIG_TOML \
                  --bootnodes "${BOOTNODES}" \
                  --raft >> node.log 2>&1 &

    # PRIVATE_CONFIG=qdata/c1/tm.ipc nohup geth --datadir qdata/dd1 $ARGS --permissioned --raftport 50401 --rpcport 22000 --port 21000 --unlock 0 --password passwords.txt 2>>qdata/logs/1.log &
    # PRIVATE_CONFIG=qdata/c2/tm.ipc nohup geth --datadir qdata/dd2 $ARGS --permissioned --raftport 50402 --rpcport 22001 --port 21001 --unlock 0 --password passwords.txt 2>>qdata/logs/2.log &
    # PRIVATE_CONFIG=qdata/c3/tm.ipc nohup geth --datadir qdata/dd3 $ARGS --permissioned --raftport 50403 --rpcport 22002 --port 21002 --unlock 0 --password passwords.txt 2>>qdata/logs/3.log &
    # PRIVATE_CONFIG=qdata/c4/tm.ipc nohup geth --datadir qdata/dd4 $ARGS --permissioned --raftport 50404 --rpcport 22003 --port 21003 --unlock 0 --password passwords.txt 2>>qdata/logs/4.log &
    # PRIVATE_CONFIG=qdata/c5/tm.ipc nohup geth --datadir qdata/dd5 $ARGS --raftport 50405 --rpcport 22004 --port 21004 --unlock 0 --password passwords.txt 2>>qdata/logs/5.log &
    # PRIVATE_CONFIG=qdata/c6/tm.ipc nohup geth --datadir qdata/dd6 $ARGS --raftport 50406 --rpcport 22005 --port 21005 --unlock 0 --password passwords.txt 2>>qdata/logs/6.log &
    # PRIVATE_CONFIG=qdata/c7/tm.ipc nohup geth --datadir qdata/dd7 $ARGS --raftport 50407 --rpcport 22006 --port 21006 --unlock 0 --password passwords.txt 2>>qdata/logs/7.log &
    fi

    mkdir quorum-node-2
    mkdir quorum-node-2/keystore
    curl -L "${NODE2_URL}" > "quorum-node-2/keystore/UTC--${NODE2_UTC}--${NODE2}" 2> /dev/null

    # echo "verySTRONGpassword2" > quorum-node-2/password
    # $QUORUM_BIN --datadir quorum-node-2 account new --password "${BASE_PATH}/quorum-node-2/password"
    # $QUORUM_BIN account list --keystore "quorum-node-2/keystore"
    for f in "${BASE_PATH}/quorum-node-2/keystore/*"
    do 
      cat $f
    done

    CONFIG2_TOML="${BASE_PATH}/config2.toml"
    $QUORUM_BIN --datadir "${BASE_PATH}/quorum-node-2" --networkid "${NETWORK_ID}" dumpconfig > $CONFIG2_TOML
    $QUORUM_BIN --config $CONFIG2_TOML --raft >> node2.log 2>&1 &

  fi
fi
