#################################################
# Query Data
#################################################

// Get Current Region Name
data "aws_region" "current" {}

// Get Availability Zones In The Region
data "aws_availability_zones" "az" {
  state = "available"
}

// Get AMI ID From the Parameter Store
data "aws_ssm_parameter" "ami" {
  name = "/amis/linux/golden-ami"
}

