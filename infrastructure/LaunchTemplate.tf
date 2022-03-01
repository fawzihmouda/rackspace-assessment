#################################################
# Launch Template
#################################################

resource "aws_launch_template" "template" {
  name                   = "webserver_launch_template"
  description            = "Launch Tempate For Webservers behind ASG"
  image_id               = data.aws_ssm_parameter.ami.value
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_web.id]

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm_instance_profile.name
  }


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web-ASG"
    }
  }
  user_data = filebase64("${path.module}/userdata.sh")
}