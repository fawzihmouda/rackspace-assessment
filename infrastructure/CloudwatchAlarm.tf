#################################################
# Cloudwatch Alarm
#################################################

//High CPU Alarm
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_description   = "This Alarm Trigger ASG to Add More Instance When the CPU Utilization is Over 40%"
  alarm_name          = "cw-hightcpu-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = "30"
  threshold           = "40"
  alarm_actions       = [aws_autoscaling_policy.high_cpu.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}

//Low CPU Alarm
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_description   = "This Alarm Trigger ASG to Add More Instance When the CPU Utilization is Less than 40%"
  alarm_name          = "cw-lowcpu-${var.client_name}-${var.environment}-${data.aws_region.current.name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  statistic           = "Average"
  period              = "30"
  threshold           = "40"
  alarm_actions       = [aws_autoscaling_policy.low_cpu.arn]
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}