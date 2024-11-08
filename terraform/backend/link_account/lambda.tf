data "archive_file" "link_account" {
  type        = "zip"
  source_dir = "backend/link_account/src"
  output_path = "backend/link_account/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "link_account" {
  function_name    = "${var.common.app_slug}_link_account"
  layers = [var.lambda_cognito_layer.arn]
  filename         = data.archive_file.link_account.output_path
  source_code_hash = data.archive_file.link_account.output_base64sha256
  role             = var.lambda_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
  timeout          = 60
  environment {
    variables = {
      USER_POOL_ID = "us-east-1_sNIwupW53",
      APP_CLIENT_IDS = "122lj1qh9e5qam3u29fpdt9ati,2kabun8v3psb5lknu4hghvo0nh,6s90hhstst6td8sdo1ntl3laet,7qoe2cb1jb3oc1oj0ari25h3sk"
      }
  }
  depends_on = [data.archive_file.link_account]
  tags       = local.common_tags
}

resource "aws_lambda_permission" "link_account" {
  statement_id  = "AllowAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.link_account.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${var.rest_api.execution_arn}/*/*/${aws_api_gateway_resource.r.path_part}"
}
