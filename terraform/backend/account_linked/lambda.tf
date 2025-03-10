data "archive_file" "account_linked" {
  type        = "zip"
  source_dir  = "backend/account_linked/src"
  output_path = "backend/account_linked/lambda_deployment_package.zip"
}

locals {
  subnet_ids = var.common.environment == "dev" ? [var.common.vpc.subnet_six.id] : [var.common.vpc.subnet_four.id]
}

resource "aws_lambda_function" "account_linked" {
  function_name    = "${var.common.app_slug}_account_linked"
  layers           = [var.lambda_cognito_layer.arn]
  filename         = data.archive_file.account_linked.output_path
  source_code_hash = data.archive_file.account_linked.output_base64sha256
  role             = var.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 60
  environment {
    variables = var.environment_variables
  }
  vpc_config {
    subnet_ids         = local.subnet_ids
    security_group_ids = [var.common.vpc.default_security_group.id]
  }
  depends_on = [data.archive_file.account_linked]
  tags       = local.common_tags
}

resource "aws_lambda_permission" "account_linked" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.account_linked.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${var.rest_api.execution_arn}/*/*/${aws_api_gateway_resource.r.path_part}"
}
