# Introduction
This repo can be used to deploy a  ```hello world ``` flask python app to AWS Fargate using terraform. Try to used best practise and an ever evolving template.

```HTTP API``` -> ```VPC Link``` -> ```ALB``` -> ```Fargate```

A final deployment could look like the table below
| environment | TF Module | State file |
| ------ | ------ | ------ |
| dev |1. Network | network-dev |
|  |2. Security | security-dev |
|  |3. Data | data-dev |
|  |4. Process | process-dev |
| qa |1. Network | network-qa |
|  |2. Security | network-qa |
|  |3. Data | network-qa |
|  |4. Process | network-qa |
| prod |1. Network | network-prod |
|  |2. Security | security-prod |
|  |3. Data | data-prod |
|  |4. Process | process-prod |

# PreRequisites 
 [aws-vault](https://github.com/99designs/aws-vault) must be installed on your local machine and a ```user``` must be configured for each environment you plan to deploy to ```dev|qa|prod```.
 [docker](https://docs.docker.com/get-docker/) must also be installed on the local machine
 [AWS CLI version 2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) must also be installed on the local machine
# Run
Amend the make file in all 4 modules and change the ```AWS_VAULT_PROFILE``` TODO: This needs to be a variabled passed in.
In ```modules/shared-config``` amend the variable values to implement a setup tailor to your spec.
### Deploy Infra
```./all_module.sh -e test -o deploy```
### Deploy Image to Fargate
Under docker_utils edit ```./deploy-image.sh``` amend variable ```AWS_REGION```, ```DOCKER_TAG```, ```ECR_REPO```, ```ECR_CLUSTER``` and ```ECR_SERVICE``` to reflect what has been deployed in AWS. then run: 
```./deploy-image.sh```
# AWS-Vault
### Basic CMD
```sh
aws-vault add weebaws
aws-vault list
aws-vault exec weebaws -- env | grep AWS
```
Remeber the user default setting like region still need to be configure at ```vi ~/.aws/config```
```
[profile weebaws]
region=eu-west-1
```
# Docker
### Get the Hashicorp Docker Image
```sh
docker pull hashicorp/terraform:light
docker pull hashicorp/terraform:0.14.6
```
### Run the container
```sh
docker run -v `pwd`:/workspace -w /workspace hashicorp/terraform:light init
docker run -v `pwd`:/workspace -w /workspace hashicorp/terraform:light apply
docker run -v `pwd`:/workspace -w /workspace hashicorp/terraform:light destroy
```
The flags
  - The ```-v``` option mounts your current working directory into the container’s /workspace directory.
  - The ```-w``` flag creates the /workspace directory and sets it as the new working directory, overwriting the terraform image’s original.
Use the following to check this: ```docker run -v `pwd`:/workspace -w /workspace --entrypoint /bin/sh hashicorp/terraform:light -c pwd```

Thanks to Victor Leong blog [artical](https://www.vic-l.com/terraform-with-docker) for the above

# Terraform

### Terraform, Docker and aws-vault
All the envirement variable created by aws-vault need to be passed onto docker and then run the terraform cmd
```sh
aws-vault exec weebaws -- docker run -i -t \
	-e AWS_VAULT \
	-e AWS_ACCESS_KEY_ID  \
	-e AWS_SECRET_ACCESS_KEY  \
	-e AWS_SESSION_TOKEN  \
	-e AWS_SECURITY_TOKEN  \
	-e AWS_SESSION_EXPIRATION  \
	-e AWS_REGION \
	-e TF_LOG=INFO  \
	-v `pwd`:/workspace -w /workspace \
	hashicorp/terraform:light init -backend=true -backend-config=backend.tfvars
```
# Debuging CMD
## Docker
### Running
```
docker ps
docker port flask-tutorial
docker run -d -p 5000:5000 flask-tutorial
```
### Clean up
```
docker image prune -a
docker container prune
docker rmi -f 270d5ba2c890
docker rmi $(docker images -a -q)
```
## AWS CLI
### AWS Fargate
Get a list of all the tast in a stopped state
```
aws-vault exec weebaws -- aws ecs list-tasks \
     --cluster xyz-dev-fargate-ecs-cluster \
     --desired-status STOPPED \
     --region eu-west-1
```
Get the reason/error message why the task is in a stooped state
```
aws-vault exec weebaws -- aws ecs describe-tasks \
     --cluster xyz-dev-fargate-ecs-cluster \
     --tasks arn:aws:ecs:eu-west-1:1234567:task/xyz-dev-fargate-ecs-cluster/bc97961f3ddcf8301438 \
     --region eu-west-1```