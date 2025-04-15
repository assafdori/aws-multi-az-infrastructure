provider "aws" {
  region = "us-west-2"
}

module "vpc" {
  source = "../../modules/vpc"

  name = "complete-example"
  vpc_cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false
  one_nat_gateway_per_az = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Environment = "dev"
    Project     = "complete-example"
    Terraform   = "true"
  }

  vpc_tags = {
    Name = "complete-example-vpc"
  }

  private_subnet_tags = {
    Tier = "Private"
  }

  public_subnet_tags = {
    Tier = "Public"
  }
}