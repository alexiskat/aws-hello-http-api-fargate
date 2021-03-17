data "aws_caller_identity" "current" {}

#Define Cluster
resource "aws_ecs_cluster" "fargate_ecs_cluster" {
  name               = "${module.config.entries.tags.prefix}fargate-ecs-cluster"
  capacity_providers = ["FARGATE"]
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}fargate-ecs-cluster"
    },
  )
}

# Define Task
# Task definitions are lists of containers grouped together.
resource "aws_ecs_task_definition" "fargate_ecs_cluster_task_definition" {
  family                   = "${module.config.entries.tags.prefix}fargate-task-definition-demo"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  memory                   = "1024"
  cpu                      = "512"
  execution_role_arn       = data.terraform_remote_state.sec_state.outputs.entries.iam_role_arn.fargate_agent_exec
  task_role_arn            = data.terraform_remote_state.sec_state.outputs.entries.iam_role_arn.fargate_pyapp
  container_definitions    = <<DEFINITION
[
  {
    "name": "demo-container",
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${module.config.entries.main.main_aws_region}.amazonaws.com/${aws_ecr_repository.fargate_ecr_repo.name}:latest",
    "memory": 512,
    "cpu": 256,
    "essential": true,
    "portMappings": 
    [
      {
        "containerPort": ${module.config.entries.network.alb_fargate_targ_hello.port},
        "hostPort": ${module.config.entries.network.alb_fargate_targ_hello.port}
      }
    ],
    "environment": [
      {
        "name": "PORT",
        "value": "${module.config.entries.network.alb_fargate_targ_hello.port}"
      },
      {
        "name": "ENABLE_LOGGING",
        "value": "true"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.fargate_pythonapp.name}",
        "awslogs-region": "eu-west-1",
        "awslogs-stream-prefix": "ecs-demo"
      }
    }
  }
]
DEFINITION
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}fargate-task-definition-demo"
    },
  )
}

#Define Service
resource "aws_ecs_service" "fargate_ecs_service" {
  name            = "${module.config.entries.tags.prefix}fargate-ecs-service"
  cluster         = aws_ecs_cluster.fargate_ecs_cluster.id
  task_definition = aws_ecs_task_definition.fargate_ecs_cluster_task_definition.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    security_groups = [
      data.terraform_remote_state.sec_state.outputs.entries.sg_id.alb_fargate
    ]
    subnets = [
      data.terraform_remote_state.net_state.outputs.entries.subnet_id.private_sub_1a_id,
      data.terraform_remote_state.net_state.outputs.entries.subnet_id.private_sub_1b_id
    ]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_alb_target_group.fargate_alb_target_http_hello.id
    container_name   = "demo-container"
    container_port   = module.config.entries.network.alb_fargate_targ_hello.port
  }
  enable_ecs_managed_tags = true
  propagate_tags          = "SERVICE"
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}fargate-ecs-service"
    },
  )
}

resource "aws_ssm_parameter" "foo" {
  name        = "${module.config.entries.tags.prefix}fargate-deployment-details"
  description = "Store the details od the ECS deployment"
  type        = "String"
  value       = <<EOF
{
"service_name": "${aws_ecs_service.fargate_ecs_service.name}",
"repo_name": "${aws_ecr_repository.fargate_ecr_repo.name}",
"cluster_name":"${aws_ecs_cluster.fargate_ecs_cluster.name}"
}
EOF
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}fargate-deployment-details"
    },
  )
}