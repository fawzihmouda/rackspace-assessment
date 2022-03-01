packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


locals {
  timestamp = formatdate("YYYY-MM-DD-hhmm", timestamp())
}


source "amazon-ebs" "amazonlinux2" {
  ami_description             = "Golden AMI for Testing"
  ami_name                    = "goldenami-${local.timestamp}"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  ssh_interface = "public_ip"
  ssh_pty = true
  subnet_filter {
    filters = {
      "tag:Name" : "SBN"
    }
  }

  vpc_filter {
    filters = {
      "tag:Name" : "VPC"
    }
  }
  security_group_filter {
    filters = {
      "tag:Name" : "SG"
    }
  }

  ssh_username = "ec2-user"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-ebs"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]

  }
  tags = {
    Name = "GoldenAMI"
  }
}
build {
  sources = [
    "source.amazon-ebs.amazonlinux2"
  ]


provisioner "shell" {
  script       = "script.sh"
}

  # provisioner "shell" {
  #   inline = [
  #     "echo Installing Updates",
  #     "sudo yum update -y",
  #     "sudo yum install -y httpd",
  #     "sudo service httpd start"
  #   ]
  # }
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
    custom_data = {
      my_custom_data = "example"
    }
  }
}

