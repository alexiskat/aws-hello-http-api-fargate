#!/bin/bash

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

echo "ECR Service: $ECR_SERVICE"
echo "ECR Cluster: $ECR_CLUSTER"

# This forces the ECS task to re-deploy the image in ECR with the newest version you've just pushed..
aws-vault exec ${USER_ID} -- aws --region $AWS_REGION ecs update-service \
                                 --cluster $ECR_CLUSTER  \
                                 --service $ECR_SERVICE \
                                 --force-new-deployment