data "aws_s3_bucket" "selected" {
  bucket = "terraform-backend-test-fawzi123"
}


resource "aws_lambda_function" "lambda_instance_refresh" {
  role          = aws_iam_role.lambda_iam_role.arn
  filename = "asg_instance_refresh.zip"
  handler       = "asg_instance_refresh.lambda_handler"
  function_name = "lambda_instance_refresh"
  runtime       = "python3.9"
  timeout = "30"

}