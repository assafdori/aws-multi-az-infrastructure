# AWS Application Load Balancer Module

This Terraform module creates an Application Load Balancer (ALB) with support for HTTP/HTTPS, access logging, and custom target groups.

## Features

- Creates an Application Load Balancer with configurable settings
- Supports both internal and internet-facing load balancers
- Automatic HTTP to HTTPS redirection when SSL certificate is provided
- Configurable health checks for target groups
- Optional access logging to S3 with lifecycle policies
- Security group with configurable rules
- Support for HTTP/2
- Customizable idle timeout
- Deletion protection enabled by default

## Usage

```hcl
module "alb" {
  source = "./modules/alb"

  name       = "my-app"
  vpc_id     = "vpc-1234567890"
  subnet_ids = ["subnet-1", "subnet-2"]

  # Optional: Enable HTTPS
  certificate_arn = "arn:aws:acm:region:account:certificate/certificate-id"

  # Optional: Enable access logs
  access_logs = {
    enabled        = true
    bucket         = "my-logs-bucket"
    prefix         = "alb-logs"
    retention_days = 90
  }

  # Optional: Configure target group
  default_target_group = {
    port     = 8080
    protocol = "HTTP"
    health_check = {
      path                = "/health"
      port                = "traffic-port"
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
      interval            = 30
      matcher             = "200-299"
    }
  }

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
| aws_lb.main | resource |
| aws_lb_listener.http | resource |
| aws_lb_listener.https | resource |
| aws_lb_target_group.default | resource |
| aws_security_group.alb | resource |
| aws_security_group_rule.alb_http_ingress | resource |
| aws_security_group_rule.alb_https_ingress | resource |
| aws_security_group_rule.alb_egress | resource |
| aws_s3_bucket.logs | resource |
| aws_s3_bucket_lifecycle_configuration.logs | resource |
| aws_s3_bucket_policy.logs | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used as a prefix for all resources | string | n/a | yes |
| vpc_id | VPC ID where the ALB will be created | string | n/a | yes |
| subnet_ids | List of subnet IDs where the ALB will be deployed | list(string) | n/a | yes |
| internal | Whether the ALB should be internal | bool | false | no |
| enable_deletion_protection | Enable deletion protection | bool | true | no |
| enable_http2 | Enable HTTP/2 | bool | true | no |
| idle_timeout | The time in seconds that the connection is allowed to be idle | number | 60 | no |
| certificate_arn | ARN of the SSL certificate | string | null | no |
| ssl_policy | SSL policy for HTTPS listeners | string | "ELBSecurityPolicy-TLS13-1-2-2021-06" | no |
| access_logs | Configuration for access logs | object | See variables.tf | no |
| default_target_group | Configuration for default target group | object | See variables.tf | no |
| tags | A map of tags to add to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the ALB |
| dns_name | DNS name of the ALB |
| zone_id | Route53 zone ID of the ALB |
| security_group_id | ID of the ALB security group |
| target_group_arn | ARN of the default target group |
| http_listener_arn | ARN of the HTTP listener |
| https_listener_arn | ARN of the HTTPS listener |
| access_logs_bucket | Name of the S3 bucket for access logs |

## Security Considerations

- HTTPS listener uses modern TLS policy by default
- Security groups are created with minimal required access
- Access logs can be enabled for audit purposes
- Deletion protection is enabled by default
- HTTP to HTTPS redirection when certificate is provided
- All resources are tagged for better tracking
- S3 bucket for access logs has lifecycle policies

## License

Apache 2 Licensed. See LICENSE for full details. 