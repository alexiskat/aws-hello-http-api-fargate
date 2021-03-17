#!/bin/bash

set -e

#if [[ $# -ne 1 ]] ; then
#  echo "Usage: $0 [aws_region in format: xx-xxxx-0]"
#  exit 99
#fi
#AWS_REGION="$1"

AWS_REGION=eu-west-1
AWS_ENV=dev
DOCKER_TAG=v1
DOCKER_IMAGE=iw-ecs-quickstart
PROJECT_CODE=xyz
USER_ID=weebaws

function get_parameter {
    SSM_PARAM_NAME=${PROJECT_CODE}-${AWS_ENV}-fargate-deployment-details    
    aws-vault exec ${USER_ID} -- aws ssm get-parameters --with-decryption --names "${SSM_PARAM_NAME}"  --query 'Parameters[*].Value' --output text
}

SSM_VALUE=$( get_parameter )
#echo "SSM_VALUE = $SSM_VALUE"
ECR_SERVICE=$(echo "$SSM_VALUE" | jq -r '.service_name')
ECR_CLUSTER=$(echo "$SSM_VALUE" | jq -r '.cluster_name')
ECR_REPO=$(echo "$SSM_VALUE" | jq -r '.repo_name')
echo "ECR Service: $ECR_SERVICE"
echo "ECR Cluster: $ECR_CLUSTER"
echo "ECR Repo   : $ECR_REPO"

ACCOUNT_ID=$(aws-vault exec ${USER_ID} -- aws sts get-caller-identity --query Account | tr -d '"')
docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
echo "Build image: ${DOCKER_IMAGE}:${DOCKER_TAG}"
#docker tag $(docker images | grep ecs-quickstart | awk '{print $3}') ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}
docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}
docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${DOCKER_TAG}
echo "Image tag: ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${DOCKER_TAG}"
aws-vault exec ${USER_ID} -- aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
#aws-vault exec ${USER_ID} -- aws ecr list-images --region ${AWS_REGION} --repository-name ${ECR_REPO} --filter 'tagStatus=UNTAGGED' --query 'imageIds[*]' --output json
docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${DOCKER_TAG}
docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}