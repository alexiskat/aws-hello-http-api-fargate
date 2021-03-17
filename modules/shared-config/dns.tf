
locals {
  environment_api_dns = local.workspace_dns[local.environment_name].api_sub_domain
  environment_api_hosted_id = local.workspace_dns[local.environment_name].api_hosted_id
  environment_primary_domain = local.workspace_dns[local.environment_name].primary_domain
}