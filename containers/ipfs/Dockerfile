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

EXPOSE 5001
EXPOSE 8080

ENTRYPOINT ["./main.sh"]
