# AWS VPC Terraform Module

This Terraform module creates a VPC with the following features:

- VPC with custom CIDR block
- Public and private subnets across multiple availability zones
- Internet Gateway for public subnets
- NAT Gateways (configurable: single, one per AZ, or one per subnet)
- Route tables for public and private subnets
- Network ACLs and Security Groups
- DNS support and hostnames

## Usage

```hcl
module "vpc" {
  source = "./modules/vpc"

  name = "my-vpc"
  vpc_cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

## Requirements

| Name | Version |
|------|----------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name to be used on all the resources as identifier | `string` | n/a | yes |
| vpc_cidr | The CIDR block for the VPC | `string` | n/a | yes |
| azs | A list of availability zones in the region | `list(string)` | n/a | yes |
| private_subnets | A list of private subnets inside the VPC | `list(string)` | `[]` | no |
| public_subnets | A list of public subnets inside the VPC | `list(string)` | `[]` | no |
| enable_nat_gateway | Should be true if you want to provision NAT Gateways | `bool` | `false` | no |
| single_nat_gateway | Should be true if you want to provision a single shared NAT Gateway across all private networks | `bool` | `false` | no |
| one_nat_gateway_per_az | Should be true if you want only one NAT Gateway per availability zone | `bool` | `false` | no |
| enable_dns_hostnames | Should be true to enable DNS hostnames in the VPC | `bool` | `true` | no |
| enable_dns_support | Should be true to enable DNS support in the VPC | `bool` | `true` | no |
| map_public_ip_on_launch | Should be true if you want to auto-assign public IP on launch | `bool` | `true` | no |
| tags | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vpc_id | The ID of the VPC |
| vpc_arn | The ARN of the VPC |
| vpc_cidr_block | The CIDR block of the VPC |
| private_subnets | List of IDs of private subnets |
| public_subnets | List of IDs of public subnets |
| nat_gateway_ids | List of NAT Gateway IDs |
| igw_id | The ID of the Internet Gateway |
| default_security_group_id | The ID of the security group created by default on VPC creation |

## License

MIT Licensed. See LICENSE for full details.