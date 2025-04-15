output "arn" {
  description = "ARN of the ALB"
  value       = aws_lb.main.arn
}

output "dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "Route53 zone ID of the ALB"
  value       = aws_lb.main.zone_id
}

output "security_group_id" {
  description = "ID of the ALB security group"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the default target group"
  value       = aws_lb_target_group.default.arn
}

output "http_listener_arn" {
  description = "ARN of the HTTP listener"
  value       = aws_lb_listener.http.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener"
  value       = try(aws_lb_listener.https[0].arn, null)
}

output "access_logs_bucket" {
  description = "Name of the S3 bucket for access logs (if enabled)"
  value       = try(aws_s3_bucket.logs[0].id, null)
} 