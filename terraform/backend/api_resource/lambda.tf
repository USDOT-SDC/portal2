data "archive_file" "f" {
  type        = "zip"
  source_dir = "backend/lambdas/${var.resource_slug}/src/"
  output_path = "backend/lambdas/${var.resource_slug}/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "f" {
  function_name    = "${var.common.app_slug}_${var.resource_slug}"
  filename         = data.archive_file.f.output_path
  source_code_hash = data.archive_file.f.output_base64sha256
  role             = var.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = var.runtime
  timeout          = 60
  environment {
    variables = var.foo.environment_variables
  }
  depends_on = [data.archive_file.f]
  tags       = local.common_tags
}

resource "aws_lambda_permission" "lp" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.f.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${var.rest_api.execution_arn}/*/${var.foo.http_method}/${aws_api_gateway_resource.r.path_part}"
}
