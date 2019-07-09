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

perform_deployment()
{
    awsRegion=$1
    if [[ -z "${AWS_ACCOUNT_ID}" || -z "${awsRegion}" || -z "${AWS_ECR_REPOSITORY_NAME}" || -z "${AWS_ECS_TASK_DEFINITION_FAMILY}" ]]
    then
        echo '....[PRVD] Skipping container deployment....'
    else
        DEFINITION_FILE="ecs-task-definition.json"
        MUNGED_FILE="ecs-task-definition-${awsRegion}-UPDATED.json"
        MUNGED_FILE_TMP="ecs-task-definition-${awsRegion}.tmp.json"

        export AWS_DEFAULT_REGION=$awsRegion
        $(aws ecr get-login --no-include-email --region ${awsRegion})

        echo '....create-repository....'
        aws ecr create-repository --repository-name ${AWS_ECR_REPOSITORY_NAME} || true

        echo '....list-images....'
        ECR_IMAGE_DIGEST=$(aws ecr list-images --repository-name ${AWS_ECR_REPOSITORY_NAME} | jq '.imageIds[0].imageDigest')

        echo '....describe-images....'
        ECR_IMAGE=$(aws ecr describe-images --repository-name "${AWS_ECR_REPOSITORY_NAME}" --image-ids imageDigest="${ECR_IMAGE_DIGEST}" | jq '.')

        echo '....load-aws-task-definition-template....'
        ECS_TASK_DEFINITION=$(cat "${DEFINITION_FILE}" | jq 'del(.taskDefinitionArn) | del(.revision) | del(.status) | del(.compatibilities) | del(.requiresAttributes)')

        echo '....file manipulation....'
        echo $ECS_TASK_DEFINITION > $DEFINITION_FILE
        sed -E "s/node:[a-zA-Z0-9\.-]+/node:${buildRef}/g" "./${DEFINITION_FILE}" > "./${MUNGED_FILE}"
        sed -E "s/\{\{awsAccountId\}\}/${AWS_ACCOUNT_ID}/g" "./${MUNGED_FILE}" > "./${MUNGED_FILE_TMP}"
        sed -E "s/\{\{awsRegion\}\}/${awsRegion}/g" "./${MUNGED_FILE_TMP}" > "./${MUNGED_FILE}"

        echo '....register-task-definition....'
        ECS_TASK_DEFINITION_ID=$(aws ecs register-task-definition --family "${AWS_ECS_TASK_DEFINITION_FAMILY}" --cli-input-json "file://${MUNGED_FILE}" | jq '.taskDefinition.taskDefinitionArn' | sed -E 's/.*\/(.*)"$/\1/')
        echo "${ECS_TASK_DEFINITION_ID}"

        sudo docker tag ${AWS_ECR_REPOSITORY_NAME}:latest "${AWS_ACCOUNT_ID}.dkr.ecr.${awsRegion}.amazonaws.com/${AWS_ECR_REPOSITORY_NAME}:${buildRef}"
        sudo docker tag ${AWS_ECR_REPOSITORY_NAME}:latest "${AWS_ACCOUNT_ID}.dkr.ecr.${awsRegion}.amazonaws.com/${AWS_ECR_REPOSITORY_NAME}:latest"
        sudo docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${awsRegion}.amazonaws.com/${AWS_ECR_REPOSITORY_NAME}:${buildRef}"
        sudo docker push "${AWS_ACCOUNT_ID}.dkr.ecr.${awsRegion}.amazonaws.com/${AWS_ECR_REPOSITORY_NAME}:latest"
    fi
}

# Preparation
echo '....Running the full continuous integration process....'
setup_deployment_tools
get_build_info

echo '....[PRVD] Docker Build....'
sudo docker build -t "${AWS_ECR_REPOSITORY_NAME}" .

echo '....[PRVD] AWS Worldwide Docker Distribution....'

perform_deployment "us-east-1"
perform_deployment "us-east-2"
perform_deployment "us-west-1"
perform_deployment "us-west-2"
perform_deployment "ap-south-1"
perform_deployment "ap-northeast-1"
perform_deployment "ap-northeast-2"
perform_deployment "ap-southeast-1"
perform_deployment "ap-southeast-2"
perform_deployment "ca-central-1"
perform_deployment "eu-central-1"
perform_deployment "eu-west-1"
perform_deployment "eu-west-2"
perform_deployment "eu-west-3"
perform_deployment "eu-north-1"
perform_deployment "sa-east-1"

# TODO: dispatch message to listeners watching for version updates

echo '....CI process completed....'
