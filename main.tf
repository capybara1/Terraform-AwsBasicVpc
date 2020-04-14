terraform {
  required_providers {
    aws = ">= 2.7.0"
  }
}


locals {
  subnet_newbits             = ceil(log(var.max_number_of_subnets, 2))
  public_subnet_cidr_blocks  = [for i in range(var.number_of_public_subnets) : cidrsubnet(var.vpc_cidr_block, local.subnet_newbits, i)]
  private_subnet_cidr_blocks = [for i in range(var.number_of_private_subnets) : cidrsubnet(var.vpc_cidr_block, local.subnet_newbits, i + var.number_of_public_subnets)]
}


data "aws_availability_zones" "available" {
  state = "available"
}


resource "aws_vpc" "default" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = var.prefix
  }
}

resource "aws_subnet" "public" {
  count                   = var.number_of_public_subnets
  vpc_id                  = aws_vpc.default.id
  availability_zone_id    = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block              = local.public_subnet_cidr_blocks[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.prefix}-Public-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.default.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.default.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
  tags = {
    Name = "${var.prefix}-Public"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.number_of_public_subnets
  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_subnet" "private" {
  count                = var.number_of_private_subnets
  vpc_id               = aws_vpc.default.id
  availability_zone_id = data.aws_availability_zones.available.zone_ids[count.index]
  cidr_block           = local.private_subnet_cidr_blocks[count.index]
  tags = {
    Name = "${var.prefix}-Private-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  count      = var.enable_nat ? var.number_of_private_subnets : 0
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "default" {
  count         = var.enable_nat ? var.number_of_private_subnets : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "${var.prefix}-${count.index + 1}"
  }
  depends_on = [aws_internet_gateway.default]
}

resource "aws_route_table" "private" {
  count  = var.enable_nat ? var.number_of_private_subnets : 0
  vpc_id = aws_vpc.default.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.default[count.index].id
  }
  tags = {
    Name = "${var.prefix}-Private-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count          = var.enable_nat ? var.number_of_private_subnets : 0
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id
}

