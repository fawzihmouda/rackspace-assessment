#################################################
# ALB Security Group
#################################################

// security Group for ALB
resource "aws_security_group" "sg_alb" {
  name        = "alb-sg-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  description = "Allow HTTP Traffic From the internet to ALB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTP Access"
    from_port   = var.sg_alb_ingress_port
    to_port     = var.sg_alb_ingress_port
    protocol    = var.sg_alb_ingress_protocol
    cidr_blocks = ["0.0.0.0/0"] #always open to the internet
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "alb-sg-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  }
}

#################################################
# Webservers Security Group
#################################################
resource "aws_security_group" "sg_web" {
  depends_on  = [aws_security_group.sg_alb]
  name        = "web-sg-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  description = "Allow HTTP Traffic from ALB"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description     = "Allow HTTP Access Only From ALB To Webservers"
    from_port       = var.sg_web_ingress_port
    to_port         = var.sg_web_ingress_port
    protocol        = var.sg_web_ingress_protocol
    security_groups = [aws_security_group.sg_alb.id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "web_alb-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  }
}

#################################################
# VPCE SSM Security Group
#################################################

resource "aws_security_group" "sg_ssm" {
  name        = "ssm-sg-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  description = "Allow HTTPS Traffic from VPC CIDR TO VPC Endpoint"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "allow https for ssm"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ssm-sg-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  }
}