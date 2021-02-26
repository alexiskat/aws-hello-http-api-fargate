
resource "aws_cloudwatch_log_group" "fargate_pythonapp" {
  name              = "${module.config.entries.tags.prefix}/fargate/pythonapp"
  retention_in_days = 1
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}/fargate/pythonapp"
    },
  )
}