

##############
# EC2 base role
##############
resource "aws_iam_role" "ec2_role" {
  name                  = "${module.config.entries.tags.prefix}ec2-base-role"
  force_detach_policies = true
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}ec2-base-role"
    },
  )
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach-policies-to-ec2-role" {
  name       = "${module.config.entries.tags.prefix}ec2-base-profile-attachment"
  roles      = [aws_iam_role.ec2_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_base_profile" {
  name = "${module.config.entries.tags.prefix}ec2-base-profile"
  role = aws_iam_role.ec2_role.name
}


##############
# Fargate Agent Excute role
#############

resource "aws_iam_role" "fargate_agent_exec_role" {
  name                  = "${module.config.entries.tags.prefix}fargate-ecs-agent-execution"
  force_detach_policies = true
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}fargate-ecs-agent-execution"
    },
  )
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "attach-policies-to-fargate-role" {
  role       = aws_iam_role.fargate_agent_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

##############
# Fargate App Role
#############

resource "aws_iam_role" "fargate_app_role" {
  name               = "${module.config.entries.tags.prefix}fargate-ecs-app-role"
  assume_role_policy = data.aws_iam_policy_document.fargate_ecs_app_assume_role_policy.json
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}fargate-ecs-app-role"
    },
  )
}

resource "aws_iam_role_policy_attachment" "fargate_base_policy_attach" {
  role       = aws_iam_role.fargate_app_role.name
  policy_arn = aws_iam_policy.farage_container_base_policy.arn
}

resource "aws_iam_policy" "farage_container_base_policy" {
  name        = "${module.config.entries.tags.prefix}fargate-ecs-app-policy"
  path        = "/"
  description = "Policy used by fargate container to gain access to AWS resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:DescribeClusters",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}




# allow role to be assumed by ecs
data "aws_iam_policy_document" "fargate_ecs_app_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}