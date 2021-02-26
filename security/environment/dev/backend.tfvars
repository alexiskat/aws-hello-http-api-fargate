bucket         = "weebaws-terraform-state"
key            = "security-terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true