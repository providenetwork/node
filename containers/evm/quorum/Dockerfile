FROM ubuntu

USER root
WORKDIR /opt

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y sudo unattended-upgrades curl wget jq vim rename
RUN wget -qO- https://deb.nodesource.com/setup_11.x | sudo -E bash -
RUN apt-get install -y git build-essential automake default-jre libcap2-bin libtool libsodium-dev python3-pip python-setuptools unbound dnsutils libunbound-dev nodejs yasm libudev-dev
RUN ln -s $(which nodejs) /usr/local/bin/node
RUN echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades

RUN wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
RUN tar -xvf go1.10.3.linux-amd64.tar.gz
RUN mv go /usr/local
ENV PATH="${PATH}:/usr/local/go/bin"

# Workaround libsodium issue
RUN /bin/bash -c 'ln -s /usr/lib/x86_64-linux-gnu/libsodium.so /usr/lib/x86_64-linux-gnu/libsodium.so.18.0.1'

RUN mkdir -p /opt/provide.network
RUN touch /opt/spec.json
RUN touch /opt/bootnodes.txt

ADD main.sh /opt/main.sh

# Istanbul install
# RUN /bin/bash -c 'git clone https://github.com/jpmorganchase/istanbul-tools.git && pushd istanbul-tools && make && popd'
RUN /bin/bash -c 'go get github.com/getamis/istanbul-tools/cmd/istanbul'

# IPFS installation
RUN /bin/bash -c 'curl https://dist.ipfs.io/go-ipfs/v0.4.17/go-ipfs_v0.4.17_linux-amd64.tar.gz -L > go-ipfs_v0.4.17_linux-amd64.tar.gz'
RUN /bin/bash -c 'tar xvvf go-ipfs_v0.4.17_linux-amd64.tar.gz && pushd go-ipfs && ./install.sh && popd'

# Quorum installation
RUN /bin/bash -c 'git clone https://github.com/jpmorganchase/quorum.git && pushd quorum && make all && popd'
RUN /bin/bash -c 'cp quorum/build/bin/bootnode /usr/local/bin/quorum-bootnode && cp quorum/build/bin/geth /usr/local/bin/quorum-geth'

# Constellation installation
RUN /bin/bash -c 'curl https://github.com/jpmorganchase/constellation/releases/download/v0.3.5-build.1/constellation-0.3.5-ubuntu1604.tar.gz -L > constellation-0.3.5-ubuntu1604.tar.gz'
RUN /bin/bash -c 'tar xvvf constellation-0.3.5-ubuntu1604.tar.gz && cp constellation-node /usr/local/bin/constellation-node'

# Tessera installation
RUN /bin/bash -c 'curl https://github.com/jpmorganchase/tessera/releases/download/tessera-0.6/tessera-app-0.6-app.jar -L > /opt/tessera-app.jar'

# remarshal installation
RUN /bin/bash -c 'git clone https://github.com/dbohdan/remarshal.git && pushd remarshal && python setup.py install && popd'

EXPOSE 4000
EXPOSE 5001
EXPOSE 8000
EXPOSE 8050
EXPOSE 8051
EXPOSE 9001
EXPOSE 30300

ENTRYPOINT ["./main.sh"]
