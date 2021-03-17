# Get the account id of the AWS ALB and ELB service account in a given region for the
# purpose of whitelisting in a S3 bucket policy.
data "aws_elb_service_account" "main" {
}
# The AWS account id
data "aws_caller_identity" "current" {
}
# The AWS partition for differentiating between AWS commercial and GovCloud
data "aws_partition" "current" {
}

locals {
  alb_logs_prefixes = ["fargate/alb"]
  bucket_arn        = "arn:${data.aws_partition.current.partition}:s3:::${module.config.entries.tags.prefix}logs"
}

locals {
  # ALB locals
  # doesn't support logging to multiple accounts
  alb_account = data.aws_caller_identity.current.account_id
  # supports logging to multiple prefixes
  alb_effect = "Allow"
  # create a list of paths, but remove any prefixes containing "" using compact
  alb_logs_path = formatlist("%s/AWSLogs", compact(local.alb_logs_prefixes))
  # finally, format the full final resources ARN list
  alb_resources = sort(formatlist("${local.bucket_arn}/%s/${local.alb_account}/*", local.alb_logs_path))
}

data "aws_iam_policy_document" "main" {
  # ALB bucket policies
  statement {
    sid    = "alb-logs-put-object"
    effect = local.alb_effect
    principals {
      type        = "AWS"
      identifiers = [data.aws_elb_service_account.main.arn]
    }
    actions   = ["s3:PutObject"]
    resources = local.alb_resources
  }
}

resource "aws_s3_bucket" "aws_logs" {
  bucket        = "${module.config.entries.tags.prefix}logs"
  acl           = "log-delivery-write"
  policy        = data.aws_iam_policy_document.main.json
  force_destroy = true

  lifecycle_rule {
    id      = "expire_all_logs"
    prefix  = "/*"
    enabled = true
    expiration {
      days = 1
    }
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}logs"
    },
  )
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.aws_logs.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}