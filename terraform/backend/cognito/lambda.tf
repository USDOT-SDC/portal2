data "archive_file" "pre_sign_up_lambda" {
  type        = "zip"
  source_file = "backend/cognito/pre_sign_up_lambda/lambda_function.py"
  output_path = "backend/cognito/pre_sign_up_lambda_deployment_package.zip"
}

resource "aws_lambda_function" "pre_sign_up_lambda" {
  function_name    = "${var.user_pool_name}_pre_sign_up"
  filename         = data.archive_file.pre_sign_up_lambda.output_path
  source_code_hash = data.archive_file.pre_sign_up_lambda.output_base64sha256
  role             = aws_iam_role.pre_sign_up_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.14"
  timeout          = 30
}

resource "aws_lambda_permission" "pre_sign_up_allow_cognito" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_sign_up_lambda.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}

data "archive_file" "pre_auth_lambda" {
  type        = "zip"
  source_file = "backend/cognito/pre_auth_lambda/lambda_function.py"
  output_path = "backend/cognito/pre_auth_lambda_deployment_package.zip"
}

resource "aws_lambda_function" "pre_auth_lambda" {
  function_name    = "${var.user_pool_name}_pre_auth_lambda"
  filename         = data.archive_file.pre_auth_lambda.output_path
  source_code_hash = data.archive_file.pre_auth_lambda.output_base64sha256
  role             = aws_iam_role.pre_auth_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.14"
  timeout          = 30
}

resource "aws_lambda_permission" "pre_auth_lambda_allow_cognito" {
  statement_id  = "AllowCognitoInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pre_auth_lambda.function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}
