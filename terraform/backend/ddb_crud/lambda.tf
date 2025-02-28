data "archive_file" "ddb_crud" {
  type        = "zip"
  source_file = "backend/ddb_crud/src/lambda_function.py"
  output_path = "backend/ddb_crud/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "ddb_crud" {
  function_name    = "${var.common.app_slug}_ddb_crud"
  filename         = data.archive_file.ddb_crud.output_path
  source_code_hash = data.archive_file.ddb_crud.output_base64sha256
  role             = aws_iam_role.ddb_crud_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.13"
  timeout          = 60
  # environment {
  #   variables = var.foo.environment_variables
  # }
  depends_on = [data.archive_file.ddb_crud]
  tags       = local.common_tags
}

resource "aws_lambda_permission" "ddb_crud" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ddb_crud.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${var.rest_api.execution_arn}/*/*/${aws_api_gateway_resource.ddb_crud.path_part}"
}
