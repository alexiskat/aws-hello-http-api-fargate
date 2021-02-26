
locals {
  name_prefix = "${local.standard.ProjectPrefix}-${local.environment_name}-"
  standard = {
    TF-Module     = local.tf_module_name
    Environment   = local.environment_name
    CreatedBy     = "Terraform"
    Owner         = "Ivon Von Weasleface"
    ProjectName   = "HelloECS",
    ProjectPrefix = "xyz",
    ProjectCode   = "123456",
  }
}