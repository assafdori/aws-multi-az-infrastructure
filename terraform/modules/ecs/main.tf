locals {
  name = var.name
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = local.name

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name = local.name
    },
  )
}

# Capacity Providers
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = concat(
    var.enable_fargate ? ["FARGATE", "FARGATE_SPOT"] : [],
    var.enable_ec2 ? ["EC2"] : []
  )

  default_capacity_provider_strategy {
    base              = var.enable_fargate ? 1 : 0
    weight            = 100
    capacity_provider = var.enable_fargate ? "FARGATE" : "EC2"
  }
}

# Security Groups
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${local.name}-tasks"
  vpc_id      = var.vpc_id
  description = "Security group for ECS tasks"

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-tasks"
    },
  )
}

# IAM Roles
resource "aws_iam_role" "ecs_task_execution" {
  name_prefix = "${local.name}-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-task-execution"
    },
  )
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# CloudWatch Logs
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/aws/ecs/${local.name}"
  retention_in_days = var.log_retention_in_days

  tags = merge(
    var.tags,
    {
      Name = "/aws/ecs/${local.name}"
    },
  )
} 