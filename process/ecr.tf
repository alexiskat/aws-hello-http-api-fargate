
resource "aws_ecr_repository_policy" "fargate_ecr_repo_policy" {
  repository = aws_ecr_repository.fargate_ecr_repo.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "Adds full ecr access to the demo repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}

resource "aws_ecr_lifecycle_policy" "fargate_ecr_repo_lifecycle_policy" {
  repository = aws_ecr_repository.fargate_ecr_repo.name
  policy     = <<EOF
{
  "rules": 
  [
    {
      "rulePriority": 1,
      "description": "Keep last 30 tagged images",
      "selection": 
      {
        "tagStatus": "tagged",
        "tagPrefixList": ["v"],
        "countType": "imageCountMoreThan",
        "countNumber": 30
      },
      "action": 
      {
        "type": "expire"
      }
    },
    {
      "rulePriority": 2,
      "description": "Expire images older than 14 days that are not tagged",
      "selection": 
      {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 14
      },
      "action": 
      {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource "aws_ecr_repository" "fargate_ecr_repo" {
  name                 = "${module.config.entries.tags.prefix}ecr-private"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}ecr-private"
    },
  )
}