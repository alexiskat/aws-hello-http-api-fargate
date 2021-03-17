
MK_PATH           :=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
MK_PARENT         :=$(realpath $(MK_PATH)../)
MODULE            := data
AWS_VAULT_PROFILE := weebaws

define DOCKER_ENV_VARIABLES
	-e AWS_VAULT \
	-e AWS_ACCESS_KEY_ID  \
	-e AWS_SECRET_ACCESS_KEY  \
	-e AWS_SESSION_TOKEN  \
	-e AWS_SECURITY_TOKEN  \
	-e AWS_SESSION_EXPIRATION  \
	-e AWS_REGION \
	-v $(MK_PARENT):/workspace \
	-w /workspace/$(MODULE)
endef

init: check-var-env
	rm -rf .terraform/
	aws-vault exec $(AWS_VAULT_PROFILE) -- docker run -i -t \
	$(DOCKER_ENV_VARIABLES) \
	hashicorp/terraform:light init -backend=true -backend-config=environment/$(env)/backend.tfvars
plan: check-var-env
	aws-vault exec $(AWS_VAULT_PROFILE) $(AWS_VAULT_FLAG)-- docker run -i -t \
    $(DOCKER_ENV_VARIABLES) \
	--entrypoint=/bin/sh \
	hashicorp/terraform:light -c 'terraform workspace select $(MODULE)-$(env) && terraform plan -var-file environment/$(env)/terraform.tfvars'
apply: check-var-env
	aws-vault exec $(AWS_VAULT_PROFILE) -- docker run -i -t \
	$(DOCKER_ENV_VARIABLES) \
	--entrypoint=/bin/sh \
	hashicorp/terraform:light -c 'terraform workspace select $(MODULE)-$(env) && terraform apply -auto-approve -var-file environment/$(env)/terraform.tfvars'
fmt: check-var-env
	aws-vault exec $(AWS_VAULT_PROFILE) -- docker run -i -t \
	$(DOCKER_ENV_VARIABLES) \
	hashicorp/terraform:light fmt --recursive
destroy: check-var-env
	aws-vault exec $(AWS_VAULT_PROFILE) -- docker run -i -t \
	$(DOCKER_ENV_VARIABLES) \
	--entrypoint=/bin/sh \
	hashicorp/terraform:light -c 'terraform workspace select $(MODULE)-$(env) && terraform destroy -auto-approve -var-file environment/$(env)/terraform.tfvars'
#
# workspace cmd's
#
ws-list: check-var-env
	aws-vault exec $(AWS_VAULT_PROFILE) -- docker run -i -t \
	$(DOCKER_ENV_VARIABLES) \
	hashicorp/terraform:light workspace list

ws-new: check-var-env
	aws-vault exec $(AWS_VAULT_PROFILE) -- docker run -i -t \
	$(DOCKER_ENV_VARIABLES) \
	hashicorp/terraform:light workspace new $(ws)

ws-select: check-var-env
	aws-vault exec $(AWS_VAULT_PROFILE) -- docker run -i -t \
	$(DOCKER_ENV_VARIABLES) \
	hashicorp/terraform:light workspace select $(ws)

ws-delete: check-var-env
	aws-vault exec $(AWS_VAULT_PROFILE) -- docker run -i -t \
	$(DOCKER_ENV_VARIABLES) \
	hashicorp/terraform:light workspace delete $(ws)

#
# utils
#
check-var-%:
	@ if [ "${${*}}" = "" ]; then echo "Environment variable $* not set"; exit 1; fi
