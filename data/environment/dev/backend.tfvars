bucket         = "weebaws-terraform-state"
key            = "data-terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true