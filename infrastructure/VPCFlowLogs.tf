#################################################
# VPC Flow Logs
#################################################

resource "aws_cloudwatch_log_group" "vpcfl_group" {

  name              = "loggroup-vpcfl"
  retention_in_days = "365"
}

resource "aws_flow_log" "vpc_flowlog" {
  depends_on               = [aws_cloudwatch_log_group.vpcfl_group]
  iam_role_arn             = aws_iam_role.flowlog_iam_role.arn
  log_destination_type     = "cloud-watch-logs"
  log_destination          = aws_cloudwatch_log_group.vpcfl_group.arn
  traffic_type             = "ALL"
  vpc_id                   = aws_vpc.vpc.id
  max_aggregation_interval = "60"

}
