bucket         = "weebaws-terraform-state"
key            = "process-terraform.tfstate"
region         = "eu-west-1"
dynamodb_table = "terraform-state-locks"
encrypt        = true