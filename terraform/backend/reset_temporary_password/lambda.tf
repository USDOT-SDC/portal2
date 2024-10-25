data "archive_file" "reset_temporary_password" {
  type        = "zip"
  source_dir = "backend/reset_temporary_password/src"
  output_path = "backend/reset_temporary_password/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "reset_temporary_password" {
  function_name    = "${var.common.app_slug}_reset_temporary_password"
  layers = [var.lambda_cognito_layer.arn]
  filename         = data.archive_file.reset_temporary_password.output_path
  source_code_hash = data.archive_file.reset_temporary_password.output_base64sha256
  role             = var.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  # environment {
  #   variables = var.foo.environment_variables
  # }
  depends_on = [data.archive_file.reset_temporary_password]
  tags       = local.common_tags
}

resource "aws_lambda_permission" "reset_temporary_password" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reset_temporary_password.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${var.rest_api.execution_arn}/*/*/${aws_api_gateway_resource.r.path_part}"
}
