locals {
  workspace_left_segment  = element(split("-", var.workspace_name), 0)
  workspace_right_segment = trimprefix(var.workspace_name, "${local.tf_module_name}-")
}

locals {
  client_name = var.client_name
}

locals {
  tf_module_name = local.workspace_left_segment
}

locals {
  environment_name = local.workspace_right_segment
}

locals {
  project_environment_name = "${local.tf_module_name}-${local.environment_name}"
}