locals {
  main_aws_region = "eu-west-1"
}

locals {
  workspace_base_ami = {
    dev  = "ami-0b48089553c9d7962"
    test = "ami-0b48089553c9d7962"
    prod = "ami-0b48089553c9d7962"
  }
}

locals {
  workspace_dns = {
    dev = {
      primary_domain = "weebaws.co.uk"
      api_sub_domain = "api.weebaws.co.uk"
      api_hosted_id = "Z48ZTUTNPL4MO"
      }
    }
  }

locals {
  workspace_network = {
    dev = {
      vpc_cidr = "192.168.0.0/16"
      public_sub_1a = {
        cidr    = "192.168.1.0/24"
        zone_id = "eu-west-1a"
      }
      public_sub_1b = {
        cidr    = "192.168.2.0/24"
        zone_id = "eu-west-1b"
      }
      private_sub_1a = {
        cidr    = "192.168.3.0/24"
        zone_id = "eu-west-1a"
      }
      private_sub_1b = {
        cidr    = "192.168.4.0/24"
        zone_id = "eu-west-1b"
      }
    }
  }
}

locals {
  workspace_alb = {
    dev = {
      fargate = {
        lisen_hello = {
          port     = 80
          protocol = "HTTP"
          type     = "forward"
        }
        target_hello = {
          port     = 5000
          protocol = "HTTP"
          type     = "ip"
          health = {
            protocol = "HTTP"
            matcher  = "200"
            path     = "/health"
          }
        }
      }
    }
  }
}

locals {
  workspace_ecr = {
    dev = {
      primary_domain = "weebaws.co.uk"
      api_sub_domain = "api.weebaws.co.uk"
      api_hosted_id = "Z48ZTUTNPL4MO"
      }
    }
  }

locals {
  workspace_ecs = {
    dev = {
      hello_task = {
        cpu = "512"
        memory = "1024"
        asg_max = 5
        asg_min = 1
        asg_mem = 80
        asg_cpu = 60
        demo_container = {
          name = "demo"
          tag = "latest"
          memory = "512"
          cpu = 256
          }
        }
      }
    }
  }