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
scriptDir=`dirname $0`
pushd "${scriptDir}/.." &>/dev/null
echo 'Working Directory =' `pwd`
bootstrap_environment

echo '....[PRVD] Docker Build....'
sudo docker build -t provide.network/node .

# TODO: update provide.network/node repository image in all supported availability zones
# TODO: dispatch message to listeners watching for version updates

# Finalization
popd &>/dev/null
echo '....CI process completed....'
