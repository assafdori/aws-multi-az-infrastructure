# AWS RDS Module

This Terraform module creates an Amazon RDS (Relational Database Service) instance with multi-AZ support and enhanced security features.

## Features

- Creates an RDS instance with optional Multi-AZ deployment
- Supports both MySQL and PostgreSQL engines
- Automatically generates and stores database credentials in AWS Secrets Manager
- Creates necessary security groups and subnet groups
- Sets up enhanced monitoring with CloudWatch
- Configurable backup and maintenance windows
- Deletion protection enabled by default

## Usage

```hcl
module "rds" {
  source = "./modules/rds"

  name          = "my-database"
  vpc_id        = "vpc-1234567890"
  subnet_ids    = ["subnet-1", "subnet-2", "subnet-3"]
  
  engine         = "postgres"
  engine_version = "14.7"
  instance_class = "db.t3.medium"
  
  database_name = "myapp"
  username      = "dbadmin"
  
  # Optional configurations
  allocated_storage = 20
  storage_type      = "gp3"
  multi_az         = true
  
  backup_retention_period = 7
  backup_window          = "03:00-04:00"
  maintenance_window     = "Mon:04:00-Mon:05:00"
  
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
| random | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |
| random | >= 3.0 |

## Resources

| Name | Type |
|------|------|
| aws_db_instance.main | resource |
| aws_db_subnet_group.main | resource |
| aws_security_group.rds | resource |
| aws_secretsmanager_secret.rds_credentials | resource |
| aws_secretsmanager_secret_version.rds_credentials | resource |
| aws_iam_role.rds_enhanced_monitoring | resource |
| aws_iam_role_policy_attachment.rds_enhanced_monitoring | resource |
| random_password.master | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used as a prefix for all resources | string | n/a | yes |
| vpc_id | VPC ID where the RDS instance will be created | string | n/a | yes |
| subnet_ids | List of subnet IDs where the RDS instance can be created | list(string) | n/a | yes |
| engine | Database engine type (mysql, postgres, etc) | string | n/a | yes |
| engine_version | Database engine version | string | n/a | yes |
| instance_class | Instance type for the RDS instance | string | n/a | yes |
| database_name | Name of the database to create | string | n/a | yes |
| username | Username for the master DB user | string | n/a | yes |
| allocated_storage | Allocated storage in gigabytes | number | 20 | no |
| storage_type | Storage type (gp2, gp3, io1) | string | "gp3" | no |
| multi_az | Enable Multi-AZ deployment | bool | true | no |
| port | Database port | number | null | no |
| backup_retention_period | Number of days to retain backups | number | 7 | no |
| backup_window | Preferred backup window | string | "03:00-04:00" | no |
| maintenance_window | Preferred maintenance window | string | "Mon:04:00-Mon:05:00" | no |
| skip_final_snapshot | Skip final snapshot when destroying the resource | bool | false | no |
| deletion_protection | Enable deletion protection | bool | true | no |
| tags | A map of tags to add to all resources | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | ID of the RDS instance |
| instance_address | Address of the RDS instance |
| instance_endpoint | Connection endpoint of the RDS instance |
| instance_port | Port of the RDS instance |
| security_group_id | ID of the security group for the RDS instance |
| subnet_group_id | ID of the DB subnet group |
| credentials_secret_arn | ARN of the Secrets Manager secret storing the database credentials |
| database_name | Name of the database |
| master_username | Username of the master DB user |

## Security Considerations

- Database credentials are automatically generated and stored in AWS Secrets Manager
- Multi-AZ deployment is enabled by default for high availability
- Deletion protection is enabled by default
- Enhanced monitoring is enabled with 60-second intervals
- Security groups are created with no inbound rules by default
- Final snapshot is enabled by default when destroying the instance
- All sensitive data is encrypted at rest

## License

Apache 2 Licensed. See LICENSE for full details. 