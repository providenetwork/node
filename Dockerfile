FROM ethereum/cpp-build-env:10

USER root
WORKDIR /opt

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y sudo unattended-upgrades curl wget
RUN wget -qO- https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN apt-get install -y build-essential automake default-jre libcap2-bin libtool libsodium-dev python3-pip python-setuptools unbound dnsutils libunbound-dev nodejs yasm libudev-dev
RUN ln -s $(which nodejs) /usr/local/bin/node
RUN echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades

RUN wget https://dl.google.com/go/go1.13.1.linux-amd64.tar.gz
RUN tar -xvf go1.13.1.linux-amd64.tar.gz
RUN mv go /usr/local
ENV PATH="${PATH}:/usr/local/go/bin"

RUN mkdir -p /opt/provide.network
RUN touch /opt/spec.json
RUN touch /opt/bootnodes.txt

ADD lib/* /opt/
ADD main.sh /opt/main.sh

# # Bcoin installation
# RUN /bin/bash -c 'git clone git://github.com/bcoin-org/bcoin.git && pushd ./bcoin && npm install --production && popd'

# # ewasm & Aleth (formerly Ethereum C++) installation
# RUN ./ewasm-cpp-eth-setup.sh

# # Geth installation
# RUN /bin/bash -c 'curl https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.8.17-8bbe7207.tar.gz -L > geth-linux-amd64-1.8.17-8bbe7207.tar.gz'
# RUN /bin/bash -c 'tar xvvf geth-linux-amd64-1.8.17-8bbe7207.tar.gz && cp geth-linux-amd64-1.8.17-8bbe7207/geth /usr/local/bin'

# # Handshake (HNS) installation
# RUN /bin/bash -c 'git clone git://github.com/handshake-org/hsd.git && pushd ./hsd && npm install --production && popd'
# RUN /bin/bash -c 'git clone git://github.com/handshake-org/hnsd.git && pushd ./hnsd && ./autogen.sh && ./configure && make && popd'
# HNScan installation
# RUN /bin/bash -c 'git clone git://github.com/providenetwork/hnscan.git && pushd ./hnscan && npm install && popd'

# IPFS installation
RUN /bin/bash -c 'curl https://dist.ipfs.io/go-ipfs/v0.4.22/go-ipfs_v0.4.22_linux-amd64.tar.gz -L > go-ipfs_v0.4.22_linux-amd64.tar.gz'
RUN /bin/bash -c 'tar xvvf go-ipfs_v0.4.22_linux-amd64.tar.gz && pushd go-ipfs && ./install.sh && popd'

# Parity installation
RUN /bin/bash -c 'curl https://releases.parity.io/ethereum/v2.5.9/x86_64-unknown-linux-gnu/parity -L > /usr/local/bin/parity && chmod +x /usr/local/bin/parity'

# # Parity AuRa-POS fork
# RUN /bin/bash -c 'curl https://sh.rustup.rs -sSf > ./rustup.sh && chmod +x ./rustup.sh && ./rustup.sh -y && source $HOME/.cargo/env'
# RUN /bin/bash -c 'git clone https://github.com/poanetwork/parity-ethereum.git && pushd parity-ethereum && git checkout aura-pos && $HOME/.cargo/bin/cargo build --release --features final && cp ./target/release/parity /usr/local/bin/parity-aura-pos && popd'

# # Quorum installation
# RUN /bin/bash -c 'git clone https://github.com/jpmorganchase/quorum.git && pushd quorum && make all && popd'
# RUN /bin/bash -c 'cp quorum/build/bin/bootnode /usr/local/bin/quorum-bootnode && cp quorum/build/bin/geth /usr/local/bin/quorum-geth'

# # Constellation installation
# RUN /bin/bash -c 'curl https://github.com/jpmorganchase/constellation/releases/download/v0.3.5-build.1/constellation-0.3.5-ubuntu1604.tar.gz -L > constellation-0.3.5-ubuntu1604.tar.gz'
# RUN /bin/bash -c 'tar xvvf constellation-0.3.5-ubuntu1604.tar.gz && cp constellation-node /usr/local/bin/constellation-node'

# # Tessera installation
# RUN /bin/bash -c 'curl https://github.com/jpmorganchase/tessera/releases/download/tessera-0.6/tessera-app-0.6-app.jar -L > /opt/tessera-app.jar'

# # remarshal installation
# RUN /bin/bash -c 'git clone https://github.com/dbohdan/remarshal.git && pushd remarshal && python setup.py install && popd'

# burrow installation
# RUN /bin/bash -c 'go get github.com/hyperledger/burrow && cd $GOPATH/src/github.com/hyperledger/burrow && make build'

EXPOSE 53
EXPOSE 4000
EXPOSE 5001
EXPOSE 5300
EXPOSE 8050
EXPOSE 8051
EXPOSE 8080
EXPOSE 8332
EXPOSE 9001
EXPOSE 12037
EXPOSE 12038
EXPOSE 12039
EXPOSE 13037
EXPOSE 13038
EXPOSE 13039
EXPOSE 14037
EXPOSE 14038
EXPOSE 14039
EXPOSE 15037
EXPOSE 15038
EXPOSE 15039
EXPOSE 15349
EXPOSE 15350
EXPOSE 15359
EXPOSE 15360
EXPOSE 18332
EXPOSE 18556
EXPOSE 30300
EXPOSE 46657

ENTRYPOINT ["./main.sh"]
