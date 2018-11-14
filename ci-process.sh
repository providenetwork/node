#!/bin/bash
# Script for Continuous Integration
set -o errexit # set -e
set -o nounset # set -u
set -o pipefail
# set -o verbose
trap die ERR
die() 
{
    echo "Failed at line $BASH_LINENO"; exit 1
}
echo Executing $0 $*

bootstrap_environment() 
{
    echo '....Setting up environment....'
    if hash docker 2>/dev/null
    then
        echo 'Using docker' `docker -v`
    else
        echo 'Installing docker'
        sudo apt-get install -y apt-transport-https \
                                ca-certificates \
                                software-properties-common
        sudo apt-get install -y docker
    fi
    echo '....Environment setup complete....'
}

# Preparation
echo '....Running the full continuous integration process....'
bootstrap_environment

echo '....[PRVD] Docker Build....'
sudo docker build -t provide.network/node .

# TODO: update provide.network/node repository image in all supported availability zones
echo '....[PRVD] Docker Build....'
sudo docker build -t provide.network/node .
echo '....[PRVD] Docker Tag....'
sudo docker tag provide.network/node:latest "085843810865.dkr.ecr.us-east-1.amazonaws.com/provide.network/node:latest"
echo '....[PRVD] Docker Push....'
$(aws ecr get-login --no-include-email --region us-east-1)
sudo docker push "085843810865.dkr.ecr.us-east-1.amazonaws.com/provide.network/node:latest"

# TODO: dispatch message to listeners watching for version updates

echo '....CI process completed....'
