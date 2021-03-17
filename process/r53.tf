
resource "aws_route53_record" "api_subdomain" {
  zone_id = module.config.entries.dns.main_public_hosted_id
  name    = "api"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.fargate_http_api_custom_domain.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.fargate_http_api_custom_domain.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}