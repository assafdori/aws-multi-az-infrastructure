locals {
  name = var.name
}

# Security Group for ALB
resource "aws_security_group" "alb" {
  name_prefix = "${local.name}-alb"
  vpc_id      = var.vpc_id
  description = "Security group for ALB ${local.name}"

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-alb"
    },
  )
}

# Allow inbound HTTP traffic
resource "aws_security_group_rule" "alb_http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTP traffic"
}

# Allow inbound HTTPS traffic
resource "aws_security_group_rule" "alb_https_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow inbound HTTPS traffic"
}

# Allow all outbound traffic
resource "aws_security_group_rule" "alb_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic"
}

# S3 bucket for access logs (if enabled)
resource "aws_s3_bucket" "logs" {
  count = var.access_logs.enabled ? 1 : 0

  bucket_prefix = "${local.name}-alb-logs-"
  force_destroy = true

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-alb-logs"
    },
  )
}

resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  count = var.access_logs.enabled ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id

  rule {
    id     = "cleanup"
    status = "Enabled"

    expiration {
      days = coalesce(var.access_logs.retention_days, 90)
    }
  }
}

# ALB policy for access logs
data "aws_iam_policy_document" "logs" {
  count = var.access_logs.enabled ? 1 : 0

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_elb_service_account.main.id}:root"]
    }
    actions = [
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.logs[0].arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "logs" {
  count = var.access_logs.enabled ? 1 : 0

  bucket = aws_s3_bucket.logs[0].id
  policy = data.aws_iam_policy_document.logs[0].json
}

# Get the AWS account ID for the ALB service account
data "aws_elb_service_account" "main" {}

# Application Load Balancer
resource "aws_lb" "main" {
  name_prefix        = substr(local.name, 0, 6)
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets           = var.subnet_ids

  enable_deletion_protection = var.enable_deletion_protection
  enable_http2              = var.enable_http2
  idle_timeout             = var.idle_timeout

  dynamic "access_logs" {
    for_each = var.access_logs.enabled ? [1] : []
    content {
      bucket  = aws_s3_bucket.logs[0].id
      prefix  = var.access_logs.prefix
      enabled = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name = local.name
    },
  )
}

# Default target group
resource "aws_lb_target_group" "default" {
  name_prefix = substr(local.name, 0, 6)
  port        = var.default_target_group.port
  protocol    = var.default_target_group.protocol
  vpc_id      = var.vpc_id

  deregistration_delay = coalesce(var.default_target_group.deregistration_delay, 300)

  dynamic "health_check" {
    for_each = var.default_target_group.health_check != null ? [var.default_target_group.health_check] : []
    content {
      enabled             = health_check.value.enabled
      path                = health_check.value.path
      port                = health_check.value.port
      protocol            = health_check.value.protocol
      timeout             = health_check.value.timeout
      healthy_threshold   = health_check.value.healthy_threshold
      unhealthy_threshold = health_check.value.unhealthy_threshold
      interval            = health_check.value.interval
      matcher             = health_check.value.matcher
    }
  }

  tags = merge(
    var.tags,
    {
      Name = local.name
    },
  )

  lifecycle {
    create_before_destroy = true
  }
}

# HTTP listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  # Redirect to HTTPS if certificate is provided, otherwise forward to target group
  dynamic "default_action" {
    for_each = var.certificate_arn != null ? [1] : []
    content {
      type = "redirect"
      redirect {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  }

  dynamic "default_action" {
    for_each = var.certificate_arn == null ? [1] : []
    content {
      type             = "forward"
      target_group_arn = aws_lb_target_group.default.arn
    }
  }
}

# HTTPS listener (if certificate is provided)
resource "aws_lb_listener" "https" {
  count = var.certificate_arn != null ? 1 : 0

  load_balancer_arn = aws_lb.main.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default.arn
  }
} 