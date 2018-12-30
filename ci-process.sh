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

setup_deployment_tools() 
{
    if hash python 2>/dev/null
    then
        echo 'Using: ' 
        python --version
    else
        echo 'Installing python'
        sudo apt-get update
        sudo apt-get -y install python2.7
    fi
    if hash pip 2>/dev/null
    then
        echo 'Using' `pip --version`
    else
        echo 'Installing python'
        sudo apt-get update
        sudo apt-get -y install python-pip
    fi
    if hash aws 2>/dev/null
    then
        echo 'Using AWS CLI: ' 
        aws --version
    else
        echo 'Installing AWS CLI'
        pip install awscli --upgrade --user
    fi
    if hash docker 2>/dev/null
    then
        echo 'Using docker' `docker -v`
    else
        echo 'Installing docker'
        sudo apt-get update
        sudo apt-get install -y apt-transport-https \
                                ca-certificates \
                                software-properties-common
        sudo apt-get install -y docker
    fi
    if hash jq 2>/dev/null
    then
        echo 'Using' `jq --version`
    else
        echo 'Installing jq'
        sudo apt-get update
        sudo apt-get -y install jq
    fi
    export PATH=~/.local/bin:$PATH
}

# Preparation
echo '....Running the full continuous integration process....'
setup_deployment_tools

echo '....[PRVD] Docker Build....'
sudo docker build -t provide.network/node .

# TODO: update provide.network/node repository image in all supported availability zones
echo '....[PRVD] Docker Build....'
sudo docker build -t provide.network/node .
echo '....[PRVD] Docker Tag....'
sudo docker tag provide.network/node:latest "085843810865.dkr.ecr.us-east-1.amazonaws.com/provide.network/node:latest"
echo '....[PRVD] Docker Push: Worldwide Distribution....'

$(aws ecr get-login --no-include-email --region us-east-1)
sudo docker push "085843810865.dkr.ecr.us-east-1.amazonaws.com/provide.network/node:latest"

$(aws ecr get-login --no-include-email --region us-east-2)
sudo docker push "085843810865.dkr.ecr.us-east-2.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region us-west-1)
sudo docker push "085843810865.dkr.ecr.us-west-1.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region us-west-2)
sudo docker push "085843810865.dkr.ecr.us-west-2.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region ap-south-1)
sudo docker push "085843810865.dkr.ecr.ap-south-1.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region ap-northeast-1)
sudo docker push "085843810865.dkr.ecr.ap-northeast-1.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region ap-northeast-2)
sudo docker push "085843810865.dkr.ecr.ap-northeast-2.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region ap-southeast-1)
sudo docker push "085843810865.dkr.ecr.ap-southeast-1.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region ap-southeast-2)
sudo docker push "085843810865.dkr.ecr.ap-southeast-2.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region ca-central-1)
sudo docker push "085843810865.dkr.ecr.ca-central-1.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region eu-central-1)
sudo docker push "085843810865.dkr.ecr.eu-central-1.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region eu-west-1)
sudo docker push "085843810865.dkr.ecr.eu-west-1.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region eu-west-2)
sudo docker push "085843810865.dkr.ecr.eu-west-2.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region eu-west-3)
sudo docker push "085843810865.dkr.ecr.eu-west-3.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region eu-north-1)
sudo docker push "085843810865.dkr.ecr.eu-north-1.amazonaws.com/provide.network/node"

$(aws ecr get-login --no-include-email --region sa-east-1)
sudo docker push "085843810865.dkr.ecr.sa-east-1.amazonaws.com/provide.network/node"


# TODO: dispatch message to listeners watching for version updates

echo '....CI process completed....'
