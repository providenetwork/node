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

get_build_info()
{
    echo '....Getting build values....'
    revNumber=$(echo `git rev-list HEAD | wc -l`)
    gitHash=`git rev-parse --short HEAD`
    gitBranch=`git rev-parse --abbrev-ref HEAD`
    buildDate=$(date '+%m.%d.%y')
    buildTime=$(date '+%H.%M.%S')
    echo "$(echo `git status` | grep "nothing to commit" > /dev/null 2>&1; if [ "$?" -ne "0" ]; then echo 'Local git status is dirty'; fi )";
    buildRef=${gitBranch}-${gitHash}-${buildDate}-${buildTime}
    echo 'Build Ref =' $buildRef
}

build_and_deploy()
{
    buildPath=$1
    dockerRepoName=$2
    containerName=$3

    pushd "${buildPath}"

    echo '....[PRVD] Docker Build....'
    sudo docker build -t "${dockerRepoName}" .

    perform_deployment "${buildPath}" "us-east-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "us-east-2" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "us-west-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "us-west-2" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "ap-south-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "ap-northeast-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "ap-northeast-2" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "ap-southeast-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "ap-southeast-2" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "ca-central-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "eu-central-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "eu-west-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "eu-west-2" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "eu-west-3" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "eu-north-1" "${dockerRepoName}" "${containerName}"
    perform_deployment "${buildPath}" "sa-east-1" "${dockerRepoName}" "${containerName}"
    
    popd

    # TODO: dispatch message to listeners watching for version updates
}

perform_deployment()
{
    buildPath=$1
    awsRegion=$2
    awsEcrRepoositoryName=$3
    awsEcsTaskDefinitionFamily=$4

    if [[ -z "${AWS_ACCOUNT_ID}" || -z "${buildPath}" || -z "${awsRegion}" || -z "${awsEcrRepoositoryName}" || -z "${awsEcsTaskDefinitionFamily}" ]]
    then
        echo '....[PRVD] Skipping container deployment....'
    else
        taskDefinitionFile="./ecs-task-definition.json"
        MUNGED_FILE="${buildPath}/ecs-task-definition-${awsRegion}-UPDATED.json"
        MUNGED_FILE_TMP="${buildPath}/ecs-task-definition-${awsRegion}.tmp.json"

        export AWS_DEFAULT_REGION=$awsRegion
        $(aws ecr get-login --no-include-email --region ${awsRegion})

        echo '....create-repository....'
        aws ecr create-repository --repository-name ${awsEcrRepoositoryName} || true

        # echo '....list-images....'
        # ecrImageDigest=$(aws ecr list-images --repository-name ${awsEcrRepoositoryName} | jq '.imageIds[0].imageDigest')

        # echo '....describe-images....'
        # ecrImage=$(aws ecr describe-images --repository-name "${awsEcrRepoositoryName}" --image-ids imageDigest="${ecrImageDigest}" | jq '.')

        echo '....load-aws-task-definition-template....'
        ecsTaskDefinition=$(cat "${taskDefinitionFile}" | jq 'del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.compatibilities) | del(.requiresAttributes)')

        echo '....file manipulation....'
        echo $ecsTaskDefinition > $taskDefinitionFile
        cat "${taskDefinitionFile}"
        sed -E "s/node:[a-zA-Z0-9\.-]+/node:${buildRef}/g" "./${taskDefinitionFile}" > "./${MUNGED_FILE}"
        sed -E "s/\{\{awsAccountId\}\}/${AWS_ACCOUNT_ID}/g" "./${MUNGED_FILE}" > "./${MUNGED_FILE_TMP}"
        sed -E "s/\{\{awsRegion\}\}/${awsRegion}/g" "./${MUNGED_FILE_TMP}" > "./${MUNGED_FILE}"

        echo '....register-task-definition....'
        ecsTaskDefinition_ID=$(aws ecs register-task-definition --family "${awsEcsTaskDefinitionFamily}" --cli-input-json "file://${MUNGED_FILE}" | jq '.taskDefinition.taskDefinitionArn' | sed -E 's/.*\/(.*)"$/\1/')
        echo "${ecsTaskDefinition_ID}"

        sudo docker tag ${awsEcrRepoositoryName}:latest "${AWS_ACCOUNT_ID}.dkr.ecr.${awsRegion}.amazonaws.com/${awsEcrRepoositoryName}:${buildRef}"
        sudo docker tag ${awsEcrRepoositoryName}:latest "${AWS_ACCOUNT_ID}.dkr.ecr.${awsRegion}.amazonaws.com/${awsEcrRepoositoryName}:latest"
        sudo docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${awsRegion}.amazonaws.com/${awsEcrRepoositoryName}:${buildRef}"
        sudo docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${awsRegion}.amazonaws.com/${awsEcrRepoositoryName}:latest"
    fi
}

# Preparation
echo '....Running the full continuous integration process....'
setup_deployment_tools
get_build_info

echo '....[PRVD] AWS Worldwide Distribution....'

# bcoin
# build_and_deploy ./containers/bcoin/bitcoin "provide.network/node/bcoin" "providenetwork-bcoin-node"
# build_and_deploy ./containers/bcoin/handshake "provide.network/node/handshake" "providenetwork-handshake-node"

# # evm
# build_and_deploy ./containers/evm/ewasm "provide.network/node/ewasm" "providenetwork-ewasm-node"
# build_and_deploy ./containers/evm/geth "provide.network/node/geth" "providenetwork-geth-node"
# build_and_deploy ./containers/evm/parity "provide.network/node/parity" "providenetwork-parity-node"
# build_and_deploy ./containers/evm/parity-aura-pos "provide.network/node/parity-aura-pos" "providenetwork-parity-aura-pos-node"
build_and_deploy ./containers/evm/quorum "provide.network/node/quorum" "providenetwork-quorum-node"

# hyperledger

echo '....CI process completed....'
