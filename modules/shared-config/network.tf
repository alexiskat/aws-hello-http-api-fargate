locals {
  environment_cidr = local.workspace_network[local.environment_name].vpc_cidr
}

locals {
  environment_public_sub_1a_cidr     = local.workspace_network[local.environment_name].public_sub_1a.cidr
  environment_public_sub_1a_zone_id  = local.workspace_network[local.environment_name].public_sub_1a.zone_id
  environment_public_sub_1b_cidr     = local.workspace_network[local.environment_name].public_sub_1b.cidr
  environment_public_sub_1b_zone_id  = local.workspace_network[local.environment_name].public_sub_1b.zone_id
  environment_private_sub_1a_cidr    = local.workspace_network[local.environment_name].private_sub_1a.cidr
  environment_private_sub_1a_zone_id = local.workspace_network[local.environment_name].private_sub_1a.zone_id
  environment_private_sub_1b_cidr    = local.workspace_network[local.environment_name].private_sub_1b.cidr
  environment_private_sub_1b_zone_id = local.workspace_network[local.environment_name].private_sub_1b.zone_id
}

locals {
  environment_alb_fargate_lisener_hello = local.workspace_alb[local.environment_name].fargate.lisen_hello
  environment_alb_fargate_target_hello  = local.workspace_alb[local.environment_name].fargate.target_hello
}