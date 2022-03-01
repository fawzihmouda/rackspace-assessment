#################################################
# EC2 Autoscaling
#################################################

resource "aws_autoscaling_group" "asg" {
  name                      = "webserver-asg"
  vpc_zone_identifier       = aws_subnet.web_subnet.*.id
  min_size                  = var.asg_min_size
  max_size                  = var.asg_max_size
  desired_capacity          = var.asg_desired_capacity
  health_check_grace_period = "300"
  force_delete              = true
  health_check_type         = "ELB"

  target_group_arns = [aws_lb_target_group.asg_target_group.arn]
  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "ASG-Instance-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.asg_target_group.arn
}

#################################################
# Autoscaling Policy (High CPU)
#################################################

resource "aws_autoscaling_policy" "high_cpu" {
  name                   = "add-instance"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "120"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

#################################################
# Autoscaling Policy (Low CPU)
#################################################
resource "aws_autoscaling_policy" "low_cpu" {
  name                   = "remove-instance"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = "120"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}