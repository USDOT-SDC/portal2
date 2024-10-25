data "archive_file" "account_linked" {
  type        = "zip"
  source_file = "backend/account_linked/src/lambda_function.py"
  output_path = "backend/account_linked/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "account_linked" {
  function_name    = "${var.common.app_slug}_account_linked"
  layers = [aws_lambda_layer_version.foo.arn]
  filename         = data.archive_file.account_linked.output_path
  source_code_hash = data.archive_file.account_linked.output_base64sha256
  role             = aws_iam_role.portal_lambdas
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  # environment {
  #   variables = var.foo.environment_variables
  # }
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
  source_arn = "${var.rest_api.execution_arn}/*/*/${aws_api_gateway_resource.account_linked.path_part}"
}
