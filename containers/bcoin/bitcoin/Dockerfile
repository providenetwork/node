FROM ubuntu

USER root
WORKDIR /opt

RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y sudo unattended-upgrades curl wget
RUN wget -qO- https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN apt-get install -y git build-essential automake default-jre libcap2-bin libtool libsodium-dev python3-pip python-setuptools unbound dnsutils libunbound-dev nodejs yasm libudev-dev
RUN ln -s $(which nodejs) /usr/local/bin/node
RUN echo -e "APT::Periodic::Update-Package-Lists \"1\";\nAPT::Periodic::Unattended-Upgrade \"1\";\n" > /etc/apt/apt.conf.d/20auto-upgrades

RUN wget https://dl.google.com/go/go1.10.3.linux-amd64.tar.gz
RUN tar -xvf go1.10.3.linux-amd64.tar.gz
RUN mv go /usr/local
ENV PATH="${PATH}:/usr/local/go/bin"

RUN mkdir -p /opt/provide.network
RUN touch /opt/spec.json
RUN touch /opt/bootnodes.txt


ADD main.sh /opt/main.sh

# IPFS installation
RUN /bin/bash -c 'curl https://dist.ipfs.io/go-ipfs/v0.4.17/go-ipfs_v0.4.17_linux-amd64.tar.gz -L > go-ipfs_v0.4.17_linux-amd64.tar.gz'
RUN /bin/bash -c 'tar xvvf go-ipfs_v0.4.17_linux-amd64.tar.gz && pushd go-ipfs && ./install.sh && popd'

# Bcoin installation
RUN /bin/bash -c 'git clone git://github.com/bcoin-org/bcoin.git && pushd ./bcoin && npm install --production && popd'

EXPOSE 53
EXPOSE 4000
EXPOSE 5001
EXPOSE 5300
EXPOSE 8000
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
