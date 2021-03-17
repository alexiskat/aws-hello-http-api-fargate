
resource "aws_cloudwatch_log_group" "dns_query" {
  name              = "${module.config.entries.tags.prefix}/dns/weebaws_co_uk"
  provider = aws.us-east
  retention_in_days = 1
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}/dns/weebaws_co_uk"
    },
  )
}