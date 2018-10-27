#!/usr/bin/env bash

echo "Installing ewasm-testnet prerequisites"
if [[ -z "${JQ_BIN_URL}" ]]; then
  JQ_BIN_URL=https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
fi
curl -L "${JQ_BIN_URL}" > /usr/local/bin/jq
chmod +x /usr/local/bin/jq

if [[ -z "${CPP_ETHEREUM_PREFIX}" ]]; then
  CPP_ETHEREUM_PREFIX=/usr/local
fi

if [[ -z "${CPP_ETHEREUM_RELEASE_TGZ_URL}" ]]; then
  CPP_ETHEREUM_RELEASE_TGZ_URL=$(curl -L https://api.github.com/repos/ethereum/cpp-ethereum/releases | jq 'first.assets|first.browser_download_url' | tr -d '"')
fi

if [[ -z "${CPP_ETHEREUM_JSON_RPC_PROXY_PY_URL}" ]]; then
  CPP_ETHEREUM_JSON_RPC_PROXY_PY_URL=https://raw.githubusercontent.com/ethereum/cpp-ethereum/develop/scripts/jsonrpcproxy.py
fi

if [[ -z "${HERA_EVMC_REF}" ]]; then
  HERA_EVMC_REF=master
fi

if [[ -z "${NETCAT_PACKAGE_URL}" ]]; then
  NETCAT_PACKAGE_URL=http://ftp.us.debian.org/debian/pool/main/n/netcat-openbsd/netcat-openbsd_1.105-7_amd64.deb
fi

echo "Prefix for cpp-ethereum install: ${CPP_ETHEREUM_PREFIX}"

echo "Installing cpp-ethereum release: ${CPP_ETHEREUM_RELEASE_TGZ_URL}"
curl -L "${CPP_ETHEREUM_RELEASE_TGZ_URL}" | tar xz -C "${CPP_ETHEREUM_PREFIX}"

echo "Installing jsonrpcproxy.py from: ${CPP_ETHEREUM_JSON_RPC_PROXY_PY_URL}"
mkdir -p "${CPP_ETHEREUM_PREFIX}/bin"
curl "${CPP_ETHEREUM_JSON_RPC_PROXY_PY_URL}" > "${CPP_ETHEREUM_PREFIX}/bin/jsonrpcproxy.py"

git clone --single-branch -b ${HERA_EVMC_REF} https://github.com/ewasm/hera.git
pushd hera
git submodule update --init --recursive
cmake -DBUILD_SHARED_LIBS=ON . && make -j8
cp src/libhera.so "${CPP_ETHEREUM_PREFIX}/lib/libhera.so"
popd

echo "Installing netcat from: ${NETCAT_PACKAGE_URL}"
curl ${NETCAT_PACKAGE_URL} > netcat.deb
dpkg -i netcat.deb
