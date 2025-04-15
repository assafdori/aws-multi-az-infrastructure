variable "name" {
  description = "Name to be used as a prefix for all resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be created"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the ALB will be deployed (should be public subnets)"
  type        = list(string)
}

variable "internal" {
  description = "Whether the ALB should be internal or internet-facing"
  type        = bool
  default     = false
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for the ALB"
  type        = bool
  default     = true
}

variable "enable_http2" {
  description = "Enable HTTP/2 on the ALB"
  type        = bool
  default     = true
}

variable "idle_timeout" {
  description = "The time in seconds that the connection is allowed to be idle"
  type        = number
  default     = 60
}

variable "access_logs" {
  description = "Configuration for ALB access logs"
  type = object({
    enabled       = bool
    bucket        = string
    prefix        = optional(string)
    retention_days = optional(number)
  })
  default = {
    enabled = false
    bucket  = ""
  }
}

variable "ssl_policy" {
  description = "SSL policy for HTTPS listeners"
  type        = string
  default     = "ELBSecurityPolicy-TLS13-1-2-2021-06"
}

variable "certificate_arn" {
  description = "ARN of the SSL certificate to use for HTTPS listeners"
  type        = string
  default     = null
}

variable "default_target_group" {
  description = "Configuration for the default target group"
  type = object({
    port                  = number
    protocol              = string
    deregistration_delay  = optional(number)
    health_check = optional(object({
      enabled             = optional(bool)
      path                = optional(string)
      port                = optional(string)
      protocol            = optional(string)
      timeout             = optional(number)
      healthy_threshold   = optional(number)
      unhealthy_threshold = optional(number)
      interval            = optional(number)
      matcher             = optional(string)
    }))
  })
  default = {
    port     = 80
    protocol = "HTTP"
    health_check = {
      enabled             = true
      path                = "/"
      port                = "traffic-port"
      protocol            = "HTTP"
      timeout             = 5
      healthy_threshold   = 3
      unhealthy_threshold = 3
      interval            = 30
      matcher             = "200-399"
    }
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 