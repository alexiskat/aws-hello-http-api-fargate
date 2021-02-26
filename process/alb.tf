
resource "aws_alb" "fargate_alb" {
  name = "${module.config.entries.tags.prefix}fargate-alb"
  subnets = [
    data.terraform_remote_state.net_state.outputs.entries.subnet_id.public_sub_1a_id,
    data.terraform_remote_state.net_state.outputs.entries.subnet_id.public_sub_1b_id
  ]
  security_groups = [
    data.terraform_remote_state.sec_state.outputs.entries.sg_id.alb_fargate
  ]
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}public-sub-1a"
    },
  )
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "fargate_alb_listener_http_hello" {
  load_balancer_arn = aws_alb.fargate_alb.id
  port              = module.config.entries.network.alb_fargate_lis_hello.port
  protocol          = module.config.entries.network.alb_fargate_lis_hello.protocol

  default_action {
    target_group_arn = aws_alb_target_group.fargate_alb_target_http_hello.id
    type             = module.config.entries.network.alb_fargate_lis_hello.type
  }
}

resource "aws_alb_target_group" "fargate_alb_target_http_hello" {
  name        = "${module.config.entries.tags.prefix}fargate-alb-http-hello"
  port        = module.config.entries.network.alb_fargate_targ_hello.port
  protocol    = module.config.entries.network.alb_fargate_targ_hello.protocol
  vpc_id      = data.terraform_remote_state.net_state.outputs.entries.vpc.mainvpc_id
  target_type = module.config.entries.network.alb_fargate_targ_hello.type

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = module.config.entries.network.alb_fargate_targ_hello.health.protocol
    matcher             = module.config.entries.network.alb_fargate_targ_hello.health.matcher
    timeout             = "3"
    path                = module.config.entries.network.alb_fargate_targ_hello.health.path
    unhealthy_threshold = "2"
  }
  depends_on = [aws_alb.fargate_alb]
}