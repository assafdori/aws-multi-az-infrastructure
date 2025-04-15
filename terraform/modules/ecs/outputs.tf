output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.main.arn
}

output "task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "task_security_group_id" {
  description = "ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for ECS tasks"
  value       = aws_cloudwatch_log_group.ecs.name
} 