# auto-scaling group
output "auto_scaling_group_arn" {
  description = "the -----"
  value = aws_autoscaling_group.ecs_asg.arn
}