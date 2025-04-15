output "instance_id" {
  description = "ID of the RDS instance"
  value       = aws_db_instance.main.id
}

output "instance_address" {
  description = "Address of the RDS instance"
  value       = aws_db_instance.main.address
}

output "instance_endpoint" {
  description = "Connection endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "instance_port" {
  description = "Port of the RDS instance"
  value       = aws_db_instance.main.port
}

output "security_group_id" {
  description = "ID of the security group for the RDS instance"
  value       = aws_security_group.rds.id
}

output "subnet_group_id" {
  description = "ID of the DB subnet group"
  value       = aws_db_subnet_group.main.id
}

output "credentials_secret_arn" {
  description = "ARN of the Secrets Manager secret storing the database credentials"
  value       = aws_secretsmanager_secret.rds_credentials.arn
}

output "database_name" {
  description = "Name of the database"
  value       = aws_db_instance.main.db_name
}

output "master_username" {
  description = "Username of the master DB user"
  value       = aws_db_instance.main.username
} 