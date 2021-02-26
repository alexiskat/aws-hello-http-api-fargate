
#
# SG used for fargate alb
#
resource "aws_security_group" "fargate_alb_sg" {
  name        = "${module.config.entries.tags.prefix}fargate-alb-sg"
  description = "SG for Fargate ALB"
  vpc_id      = data.terraform_remote_state.net_state.outputs.entries.vpc.mainvpc_id
  tags = merge(
    module.config.entries.tags.standard,
    {
      "Name" = "${module.config.entries.tags.prefix}fargate-alb-sg"
    },
  )
}

resource "aws_security_group_rule" "fargate_alb_sg_ingress_01" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fargate_alb_sg.id
}

resource "aws_security_group_rule" "fargate_alb_sg_egress_01" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.fargate_alb_sg.id
}