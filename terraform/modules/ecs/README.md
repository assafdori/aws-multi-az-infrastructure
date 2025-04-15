# AWS ECS Module

This Terraform module creates an Amazon ECS (Elastic Container Service) cluster with support for both Fargate and EC2 capacity providers.

## Features

- Creates an ECS cluster with optional Container Insights
- Supports both Fargate and EC2 capacity providers
- Creates necessary IAM roles and policies
- Sets up CloudWatch log groups for container logs
- Creates security groups for ECS tasks
- Configurable through variables

## Usage

```hcl
module "ecs" {
  source = "./modules/ecs"

  name = "my-ecs-cluster"
  vpc_id = "vpc-1234567890"

  # Optional configurations
  enable_container_insights = true
  enable_fargate           = true
  enable_ec2              = false
  log_retention_in_days   = 30

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Resources

| Name | Type |
|------|------|
| aws_ecs_cluster.main | resource |
| aws_ecs_cluster_capacity_providers.main | resource |
| aws_security_group.ecs_tasks | resource |
| aws_iam_role.ecs_task_execution | resource |
| aws_iam_role_policy_attachment.ecs_task_execution | resource |
| aws_cloudwatch_log_group.ecs | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used as a prefix for all resources | string | n/a | yes |
| vpc_id | VPC ID where the ECS cluster will be created | string | n/a | yes |
| enable_container_insights | Enable CloudWatch Container Insights for the cluster | bool | true | no |
| enable_fargate | Enable Fargate capacity provider | bool | true | no |
| enable_ec2 | Enable EC2 capacity provider | bool | false | no |
| log_retention_in_days | Number of days to retain CloudWatch logs | number | 30 | no |
| tags | A map of tags to add to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_id | ID of the ECS cluster |
| cluster_name | Name of the ECS cluster |
| cluster_arn | ARN of the ECS cluster |
| task_execution_role_arn | ARN of the ECS task execution role |
| task_security_group_id | ID of the security group for ECS tasks |
| cloudwatch_log_group_name | Name of the CloudWatch log group for ECS tasks |

## Security Considerations

- The module creates a task execution IAM role with minimal required permissions
- Security groups are created with no inbound rules by default
- CloudWatch logs are encrypted by default
- Container Insights can be enabled for enhanced monitoring

## License

Apache 2 Licensed. See LICENSE for full details. 