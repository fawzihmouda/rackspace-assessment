####################################################################################
# This is A Temporary VPC For Packer, It will be destroyed once Packer Build the Image
####################################################################################


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}


data "aws_availability_zones" "az" {
  state = "available"
}


provider "aws" {}

variable "github_runner_ip" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "192.168.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "VPC"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-igw"
  }
}

resource "aws_subnet" "packer_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "192.168.0.0/27"
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "SBN"
  }
}
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "rt-packer-public"
  }
}
resource "aws_route_table_association" "packer_subnet_association" {
  subnet_id      = aws_subnet.packer_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_security_group" "sg_packer" {
  name        = "packer-sg"
  description = "Allow SSH from Github Actions Runner IP to Packer Instance"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.github_runner_ip]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "SG"
  }
}