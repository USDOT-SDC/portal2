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

data "archive_file" "get_user_info" {
  type        = "zip"
  source_file = "${path.module}/lambdas/get_user_info/src/lambda_function.py"
  output_path = "${path.module}/lambdas/get_user_info/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "get_user_info" {
  function_name    = "${var.common.app_slug}_get_user_info"
  filename         = data.archive_file.get_user_info.output_path
  source_code_hash = data.archive_file.get_user_info.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
  environment {
    variables = {
      RESTAPIID = local.restapi_id
      AUTHORIZERID = local.authorizer_id
      TABLENAME_USER_STACKS = local.tablename_user_stacks
      TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
      TABLENAME_TRUSTED_USERS = local.tablename_trusted_users
      TABLENAME_AUTOEXPORT_USERS = local.tablename_autoexport_users
    }
  }
  depends_on       = [data.archive_file.get_user_info]
  tags             = local.common_tags
}
