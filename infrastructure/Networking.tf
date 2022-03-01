#############################################
# VPC
#############################################

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.global_tags,
    {
      Name = "vpc-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
    }
  )
}

#############################################
# Internet Gateway
#############################################

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-${var.environment}-${data.aws_region.current.name}"
  }
}

#############################################
# Private Web Subnet
#############################################

resource "aws_subnet" "web_subnet" {
  count                   = length(data.aws_availability_zones.az.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 0)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "sbn-web-${var.client_name}-${var.environment}-az${count.index + 1}"
  }
}

#############################################
# Public ALB Subnet
#############################################

resource "aws_subnet" "alb_subnet" {
  count                   = length(data.aws_availability_zones.az.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 3)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "sbn-alb-${var.client_name}-${var.environment}-az${count.index + 1}"
  }
}

#############################################
# Public NAT Subnet
#############################################

resource "aws_subnet" "nat_subnet" {
  count                   = length(data.aws_availability_zones.az.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 6)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "sbn-nat-${var.client_name}-${var.environment}-az${count.index + 1}"
  }
}

#############################################
# VPC Endpoins Subnet
#############################################

resource "aws_subnet" "endpoint_subnet" {
  count                   = length(data.aws_availability_zones.az.names)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index + 9)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "sbn-endpoint-${var.client_name}-${var.environment}-az${count.index + 1}"
  }
}

###########################################
# Public NAT Gateway
###########################################

// Nat Gateway
resource "aws_nat_gateway" "nat" {
  depends_on    = [aws_internet_gateway.igw]
  count         = length(data.aws_availability_zones.az.names)
  allocation_id = aws_eip.eip.*.id[count.index]
  subnet_id     = aws_subnet.nat_subnet.*.id[count.index]

  tags = {
    Name = "nat-${var.client_name}-${var.environment}-az${count.index + 1}"
  }
}

// Elastic IP for NAT
resource "aws_eip" "eip" {
  depends_on = [aws_internet_gateway.igw]
  count      = length(data.aws_availability_zones.az.names)
  vpc        = true

  tags = {
    name = "eip-nat-${var.client_name}-${var.environment}-az${count.index + 1}"
  }
}

#################################################
# Public Route Table For NAT & ALB Subnets
#################################################

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-public-${var.client_name}-${var.environment}"
  }
}

resource "aws_route_table_association" "nat_subnet_association" {
  count          = length(data.aws_availability_zones.az.names)
  subnet_id      = aws_subnet.nat_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "alb_subnet_association" {
  count          = length(data.aws_availability_zones.az.names)
  subnet_id      = aws_subnet.alb_subnet.*.id[count.index]
  route_table_id = aws_route_table.public_rt.id
}

#################################################
# Private Route Table for WEB Subnets
#################################################

resource "aws_route_table" "private_rt" {
  count  = length(data.aws_availability_zones.az.names)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.*.id[count.index]
  }

  tags = {
    Name = "rt-private-${var.client_name}-${var.environment}"
  }
}

resource "aws_route_table_association" "web_subnet_association" {
  count          = length(data.aws_availability_zones.az.names)
  subnet_id      = aws_subnet.web_subnet.*.id[count.index]
  route_table_id = aws_route_table.private_rt.*.id[count.index]
}

#################################################
# Private Route Table For VPC Endpoint
#################################################

resource "aws_route_table" "endpoint_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rt-endpoint-${var.client_name}-${var.environment}"
  }
}

resource "aws_route_table_association" "endpoint_association" {
  count          = length(data.aws_availability_zones.az.names)
  subnet_id      = aws_subnet.endpoint_subnet.*.id[count.index]
  route_table_id = aws_route_table.endpoint_rt.id
}

#################################################
# VPC Endpoint For Session Manager
#################################################

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id             = aws_vpc.vpc.id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg_ssm.id]
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  subnet_ids         = aws_subnet.endpoint_subnet.*.id
  tags = {
    Name = "vpce-ssmmessage-${var.client_name}-${var.environment}"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id             = aws_vpc.vpc.id
  vpc_endpoint_type  = "Interface"
  security_group_ids = [aws_security_group.sg_ssm.id]
  service_name       = "com.amazonaws.${data.aws_region.current.name}.ssm"
  subnet_ids         = aws_subnet.endpoint_subnet.*.id

  tags = {
    Name = "vpce-ssm-${var.client_name}-${var.environment}"
  }
}

