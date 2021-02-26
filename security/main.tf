
data "terraform_remote_state" "net_state" {
  backend = "s3"
  config = {
    bucket = "weebaws-terraform-state"
    key    = "env:/network-${module.config.entries.main.environment_name}/network-terraform.tfstate"
    region = "eu-west-1"
  }
}