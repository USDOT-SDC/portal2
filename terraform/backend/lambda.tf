data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "${path.module}/lambdas/hello_world/src/lambda_function.py"
  output_path = "${path.module}/lambdas/hello_world/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "hello_world" {
  function_name    = "${var.common.app_slug}_hello_world"
  filename         = data.archive_file.hello_world.output_path
  source_code_hash = data.archive_file.hello_world.output_base64sha256
  role             = aws_iam_role.hello_world.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
  depends_on       = [data.archive_file.hello_world]
  tags             = local.common_tags
}
