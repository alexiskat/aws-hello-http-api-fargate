
output "entries" {
  value = {
    sg_id = {
      alb_fargate = aws_security_group.fargate_alb_sg.id
    }
    iam_role_id = {
      fargate_agent_exec = aws_iam_role.fargate_agent_exec_role.id
      fargate_pyapp      = aws_iam_role.fargate_app_role.id
      ec2_base           = aws_iam_role.ec2_role.id
    }
    iam_role_name = {
      fargate_agent_exec = aws_iam_role.fargate_agent_exec_role.name
      fargate_pyapp      = aws_iam_role.fargate_app_role.name
      ec2_base           = aws_iam_role.ec2_role.name
    }
    iam_role_arn = {
      fargate_agent_exec = aws_iam_role.fargate_agent_exec_role.arn
      fargate_pyapp      = aws_iam_role.fargate_app_role.arn
    }
    iam_profile_name = {
      ec2_base = aws_iam_instance_profile.ec2_base_profile.name
    }
  }
}