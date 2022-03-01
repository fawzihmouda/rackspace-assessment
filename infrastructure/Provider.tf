terraform {

  backend "s3" {

    bucket = "fawzihmouda-terraform-statefile"
    key    = "tfstate"
    region = "ap-southeast-2"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}