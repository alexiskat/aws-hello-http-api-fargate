
# setup the private link to the VPC
resource "aws_apigatewayv2_vpc_link" "fargate_http_api_integration" {
  name = "${module.config.entries.tags.prefix}api-to-fargate-alb"
  security_group_ids = [
    data.terraform_remote_state.sec_state.outputs.entries.sg_id.alb_fargate
  ]
  subnet_ids = [
    data.terraform_remote_state.net_state.outputs.entries.subnet_id.private_sub_1a_id,
    data.terraform_remote_state.net_state.outputs.entries.subnet_id.private_sub_1b_id
  ]
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}api-to-fargate-alb"
    },
  )
}

# create the Auth for the HTTP API gateway
resource "aws_apigatewayv2_api" "fargate_http_api" {
  name          = "${module.config.entries.tags.prefix}fargate-http-api"
  protocol_type = "HTTP"
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}fargate-http-api"
    },
  )
}

# attach the HTTP API GW to the VPC link and ALB
resource "aws_apigatewayv2_integration" "fargate_http_api_integration" {
  api_id                 = aws_apigatewayv2_api.fargate_http_api.id
  integration_type       = "HTTP_PROXY"
  connection_type        = "VPC_LINK"
  connection_id          = aws_apigatewayv2_vpc_link.fargate_http_api_integration.id
  integration_uri        = aws_alb_listener.fargate_alb_listener_http_hello.arn
  integration_method     = "ANY"
  payload_format_version = "1.0"
}

resource "aws_apigatewayv2_stage" "fargate_http_api_stage_v1" {
  api_id      = aws_apigatewayv2_api.fargate_http_api.id
  name        = "v1"
  auto_deploy = true
  default_route_settings {
    throttling_burst_limit = 1001
    throttling_rate_limit  = 501
  }
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.fargate_api_http.arn
    format = jsonencode(
      {
        path                     = "$context.path"
        protocol                 = "$context.protocol"
        time                     = "$context.requestTime"
        route_key                = "$context.routeKey"
        stage                    = "$context.stage"
        status                   = "$context.status"
        auth_status              = "$context.authorizer.status"
        aws_endpoint             = "$context.awsEndpointRequestId"
        domain_name              = "$context.domainName"
        domain_prefix            = "$context.domainPrefix"
        err_msg                  = "$context.error.message"
        err_string               = "$context.error.messageString"
        err_response             = "$context.error.responseType"
        request_id               = "$context.extendedRequestId"
        http_method              = "$context.httpMethod"
        cognito_auth_provider    = "$context.identity.cognitoAuthenticationProvider"
        cognito_auth_type        = "$context.identity.cognitoAuthenticationType"
        cognito_identity_id      = "$context.identity.cognitoIdentityId"
        cognito_identity_pool_id = "$context.identity.cognitoIdentityPoolId"
        principa_ord_id          = "$context.identity.principalOrgId"
        source_ip                = "$context.identity.sourceIp"
        user                     = "$context.identity.user"
        user_agent               = "$context.identity.userAgent"
        integration_error        = "$context.integration.error"
        integration_int_status   = "$context.integration.integrationStatus"
        integration_status       = "$context.integration.status"
        integration_error_msg    = "$context.integrationErrorMessage"
      }
    )
  }
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}-stage"
    },
  )
}

resource "aws_apigatewayv2_route" "fargate_http_api_proxy" {
  api_id    = aws_apigatewayv2_api.fargate_http_api.id
  route_key = "ANY /{proxy+}"
  #route_key          = "$default"
  authorization_type = "NONE"
  target             = "integrations/${aws_apigatewayv2_integration.fargate_http_api_integration.id}"
}

resource "aws_apigatewayv2_domain_name" "fargate_http_api_custom_domain" {
  domain_name = module.config.entries.dns.api_dns
  domain_name_configuration {
    certificate_arn = data.terraform_remote_state.sec_state.outputs.entries.acm_cert_arn.api
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}api-custom-domain"
    },
  )
}

resource "aws_apigatewayv2_api_mapping" "api_dns_mappings" {
  api_id      = aws_apigatewayv2_api.fargate_http_api.id
  domain_name = aws_apigatewayv2_domain_name.fargate_http_api_custom_domain.id
  stage       = aws_apigatewayv2_stage.fargate_http_api_stage_v1.id
}