#############################################
# Event Bridge
#############################################

resource "aws_cloudwatch_event_rule" "packer_update" {

  name        = "event_update_ami"
  description = "Trigger An Event Everytime Packer Update the Image in the Parameter Store"

  event_pattern = <<EOF
{
  "source": ["aws.ssm"],
  "detail-type": ["Parameter Store Change"]
}
EOF
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  depends_on = [aws_lambda_function.lambda_instance_refresh]

  rule      = aws_cloudwatch_event_rule.packer_update.name
  target_id = "SentToLambda"
  arn       = aws_lambda_function.lambda_instance_refresh.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_instance_refresh.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.packer_update.arn
}