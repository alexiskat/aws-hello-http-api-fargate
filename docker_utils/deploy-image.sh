#!/bin/bash

set -e

#if [[ $# -ne 1 ]] ; then
#  echo "Usage: $0 [aws_region in format: xx-xxxx-0]"
#  exit 99
#fi
#AWS_REGION="$1"

AWS_REGION=eu-west-1
DOCKER_TAG=latest
PROJECT_CODE=xyz
ENV=dev
USER_ID=weebaws

function get_parameter {
    SSM_PARAM_NAME=${PROJECT_CODE}-${ENV}-fargate-deployment-details    
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
docker build -t iw-ecs-quickstart:${DOCKER_TAG} .
docker tag $(docker images | grep ecs-quickstart | awk '{print $3}') ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}
aws-vault exec ${USER_ID} -- aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}
# 
# # This forces the ECS task to re-deploy the image in ECR with the newest version you've just pushed..
# aws-vault exec ${USER_ID} -- aws --region $AWS_REGION ecs update-service \
#                               --cluster $ECR_CLUSTER  \
#                               --service $ECR_SERVICE \
#                               --force-new-deployment


#  NOTES:
 # aws ecr get-login-password --region eu-west-1 | docker login --username AWS --password-stdin 339638031741.dkr.ecr.eu-west-1.amazonaws.com
 # docker build -t xyz-dev-ecr-private .
 # docker tag xyz-dev-ecr-private:latest 339638031741.dkr.ecr.eu-west-1.amazonaws.com/xyz-dev-ecr-private:latest
 # docker push 339638031741.dkr.ecr.eu-west-1.amazonaws.com/xyz-dev-ecr-private:latest