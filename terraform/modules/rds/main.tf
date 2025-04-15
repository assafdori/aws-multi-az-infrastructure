locals {
  name = var.name
  port = coalesce(var.port, var.engine == "postgres" ? 5432 : 3306)
}

# Random password for RDS master user
resource "random_password" "master" {
  length  = 16
  special = false
}

# Store the generated password in AWS Secrets Manager
resource "aws_secretsmanager_secret" "rds_credentials" {
  name_prefix = "${local.name}-credentials"
  description = "Credentials for RDS instance ${local.name}"

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-credentials"
    },
  )
}

resource "aws_secretsmanager_secret_version" "rds_credentials" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = var.username
    password = random_password.master.result
    engine   = var.engine
    host     = aws_db_instance.main.address
    port     = local.port
    dbname   = var.database_name
  })
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${local.name}-rds"
  vpc_id      = var.vpc_id
  description = "Security group for RDS instance ${local.name}"

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-rds"
    },
  )
}

# DB Subnet Group
resource "aws_db_subnet_group" "main" {
  name_prefix = local.name
  subnet_ids  = var.subnet_ids
  description = "Subnet group for RDS instance ${local.name}"

  tags = merge(
    var.tags,
    {
      Name = local.name
    },
  )
}

# RDS Instance
resource "aws_db_instance" "main" {
  identifier_prefix = local.name

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = var.storage_type

  multi_az = var.multi_az

  db_name  = var.database_name
  username = var.username
  password = random_password.master.result
  port     = local.port

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  backup_retention_period = var.backup_retention_period
  backup_window          = var.backup_window
  maintenance_window     = var.maintenance_window

  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection

  # Enhanced monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_enhanced_monitoring.arn

  tags = merge(
    var.tags,
    {
      Name = local.name
    },
  )
}

# IAM role for Enhanced Monitoring
resource "aws_iam_role" "rds_enhanced_monitoring" {
  name_prefix = "${local.name}-monitoring"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "monitoring.rds.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name = "${local.name}-monitoring"
    },
  )
}

resource "aws_iam_role_policy_attachment" "rds_enhanced_monitoring" {
  role       = aws_iam_role.rds_enhanced_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
} 