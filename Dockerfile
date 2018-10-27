FROM ethereum/cpp-build-env

USER root
WORKDIR /opt

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y sudo unattended-upgrades curl golang-go
RUN echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades

RUN mkdir -p /opt/provide.network
RUN touch /opt/spec.json
RUN touch /opt/bootnodes.txt

ADD lib/* /opt/
ADD main.sh /opt/main.sh

# ewasm & Aleth (formerly Ethereum C++) installation
RUN ./ewasm-cpp-eth-setup.sh

# Geth installation
RUN /bin/bash -c 'curl https://gethstore.blob.core.windows.net/builds/geth-linux-amd64-1.8.17-8bbe7207.tar.gz -L > geth-linux-amd64-1.8.17-8bbe7207.tar.gz'
RUN /bin/bash -c 'tar xvvf geth-linux-amd64-1.8.17-8bbe7207.tar.gz && cp geth-linux-amd64-1.8.17-8bbe7207/geth /usr/local/bin'

# IPFS installation
RUN /bin/bash -c 'curl https://dist.ipfs.io/go-ipfs/v0.4.17/go-ipfs_v0.4.17_linux-amd64.tar.gz -L > go-ipfs_v0.4.17_linux-amd64.tar.gz'
RUN /bin/bash -c 'tar xvvf go-ipfs_v0.4.17_linux-amd64.tar.gz && pushd go-ipfs && ./install.sh && popd'

# Parity installation
RUN /bin/bash -c 'bash <(curl https://get.parity.io -L)'

# Quorum installation
RUN /bin/bash -c 'git clone https://github.com/jpmorganchase/quorum.git && pushd quorum && make all && popd'
RUN /bin/bash -c 'cp quorum/build/bin/bootnode /usr/local/bin/quorum-bootnode && cp quorum/build/bin/geth /usr/local/bin/quorum-geth'

# Constellation installation
RUN /bin/bash -c 'curl https://github.com/jpmorganchase/constellation/releases/download/v0.3.5-build.1/constellation-0.3.5-ubuntu1604.tar.gz -L > constellation-0.3.5-ubuntu1604.tar.gz'
RUN /bin/bash -c 'tar xvvf constellation-0.3.5-ubuntu1604.tar.gz && cp constellation-node /usr/local/bin/constellation-node'

EXPOSE 5001
EXPOSE 8050
EXPOSE 8051
EXPOSE 8080
EXPOSE 30300

ENTRYPOINT ["./main.sh"]
