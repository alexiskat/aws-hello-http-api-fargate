
locals {
  environment_task_hello_cpu = local.workspace_ecs[local.environment_name].hello_task.cpu
  environment_task_hello_mem = local.workspace_ecs[local.environment_name].hello_task.memory
  environment_task_hello_asg_max = local.workspace_ecs[local.environment_name].hello_task.asg_max
  environment_task_hello_asg_min = local.workspace_ecs[local.environment_name].hello_task.asg_min
  environment_task_hello_asg_mem = local.workspace_ecs[local.environment_name].hello_task.asg_mem
  environment_task_hello_asg_cpu = local.workspace_ecs[local.environment_name].hello_task.asg_cpu
  environment_task_hello_cont_demo_name = local.workspace_ecs[local.environment_name].hello_task.demo_container.name
  environment_task_hello_cont_demo_tag = local.workspace_ecs[local.environment_name].hello_task.demo_container.tag
  environment_task_hello_cont_demo_mem = local.workspace_ecs[local.environment_name].hello_task.demo_container.memory
  environment_task_hello_cont_demo_cpu = local.workspace_ecs[local.environment_name].hello_task.demo_container.cpu
}