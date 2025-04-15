locals {
  max_subnet_length = max(
    length(var.private_subnets),
    length(var.public_subnets)
  )
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_az ? length(var.azs) : local.max_subnet_length
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    {
      Name = var.name
    },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null

  tags = merge(
    {
      Name = format("%s-private-%s", var.name, element(var.azs, count.index))
      Tier = "Private"
    },
    var.tags,
    var.private_subnet_tags,
  )
}

resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = length(regexall("^[a-z]{2}-", element(var.azs, count.index))) > 0 ? element(var.azs, count.index) : null
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = format("%s-public-%s", var.name, element(var.azs, count.index))
      Tier = "Public"
    },
    var.tags,
    var.public_subnet_tags,
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = var.name
    },
    var.tags,
    var.igw_tags,
  )
}

resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  domain = "vpc"

  tags = merge(
    {
      Name = format("%s-%s", var.name, element(var.azs, count.index))
    },
    var.tags,
    var.nat_eip_tags,
  )
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)

  tags = merge(
    {
      Name = format("%s-%s", var.name, element(var.azs, count.index))
    },
    var.tags,
    var.nat_gateway_tags,
  )

  depends_on = [aws_internet_gateway.main]
}

resource "aws_route_table" "private" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = format("%s-private-%s", var.name, element(var.azs, count.index))
    },
    var.tags,
    var.private_route_table_tags,
  )
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? length(var.private_subnets) : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.main.*.id, count.index)
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = format("%s-public", var.name)
    },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      Name = format("%s-default", var.name)
    },
    var.tags,
    var.default_security_group_tags,
  )
}