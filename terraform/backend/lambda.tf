data "archive_file" "hello_world" {
  type        = "zip"
  source_file = "${path.module}/lambdas/hello_world/src/lambda_function.py"
  output_path = "${path.module}/lambdas/hello_world/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "hello_world" {
  function_name    = "${var.common.app_slug}_hello_world"
  filename         = data.archive_file.hello_world.output_path
  source_code_hash = data.archive_file.hello_world.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.hello_world]
  tags             = local.common_tags
}

data "archive_file" "data_dictionary" {
  type        = "zip"
  source_file = "${path.module}/lambdas/data_dictionary/src/lambda_function.py"
  output_path = "${path.module}/lambdas/data_dictionary/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "data_dictionary" {
  function_name    = "${var.common.app_slug}_data_dictionary"
  filename         = data.archive_file.data_dictionary.output_path
  source_code_hash = data.archive_file.data_dictionary.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.data_dictionary]
  tags             = local.common_tags
}

data "archive_file" "desired_instance_types" {
  type        = "zip"
  source_file = "${path.module}/lambdas/desired_instance_types/src/lambda_function.py"
  output_path = "${path.module}/lambdas/desired_instance_types/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "desired_instance_types" {
  function_name    = "${var.common.app_slug}_desired_instance_types"
  filename         = data.archive_file.desired_instance_types.output_path
  source_code_hash = data.archive_file.desired_instance_types.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.desired_instance_types]
  tags             = local.common_tags
}

data "archive_file" "download_url" {
  type        = "zip"
  source_file = "${path.module}/lambdas/download_url/src/lambda_function.py"
  output_path = "${path.module}/lambdas/download_url/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "download_url" {
  function_name    = "${var.common.app_slug}_download_url"
  filename         = data.archive_file.download_url.output_path
  source_code_hash = data.archive_file.download_url.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.download_url]
  tags             = local.common_tags
}

data "archive_file" "export_objects" {
  type        = "zip"
  source_file = "${path.module}/lambdas/export_objects/src/lambda_function.py"
  output_path = "${path.module}/lambdas/export_objects/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "export_objects" {
  function_name    = "${var.common.app_slug}_export_objects"
  filename         = data.archive_file.export_objects.output_path
  source_code_hash = data.archive_file.export_objects.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.export_objects]
  tags             = local.common_tags
}

data "archive_file" "export_request" {
  type        = "zip"
  source_file = "${path.module}/lambdas/export_request/src/lambda_function.py"
  output_path = "${path.module}/lambdas/export_request/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "export_request" {
  function_name    = "${var.common.app_slug}_export_request"
  filename         = data.archive_file.export_request.output_path
  source_code_hash = data.archive_file.export_request.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.export_request]
  tags             = local.common_tags
}

data "archive_file" "export_table" {
  type        = "zip"
  source_file = "${path.module}/lambdas/export_table/src/lambda_function.py"
  output_path = "${path.module}/lambdas/export_table/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "export_table" {
  function_name    = "${var.common.app_slug}_export_table"
  filename         = data.archive_file.export_table.output_path
  source_code_hash = data.archive_file.export_table.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.export_table]
  tags             = local.common_tags
}

data "archive_file" "get_health" {
  type        = "zip"
  source_file = "${path.module}/lambdas/get_health/src/lambda_function.py"
  output_path = "${path.module}/lambdas/get_health/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "get_health" {
  function_name    = "${var.common.app_slug}_get_health"
  filename         = data.archive_file.get_health.output_path
  source_code_hash = data.archive_file.get_health.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.get_health]
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
  runtime          = "python3.12"
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

data "archive_file" "instance_status" {
  type        = "zip"
  source_file = "${path.module}/lambdas/instance_status/src/lambda_function.py"
  output_path = "${path.module}/lambdas/instance_status/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "instance_status" {
  function_name    = "${var.common.app_slug}_instance_status"
  filename         = data.archive_file.instance_status.output_path
  source_code_hash = data.archive_file.instance_status.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.instance_status]
  tags             = local.common_tags
}

data "archive_file" "manage_workstation_schedule" {
  type        = "zip"
  source_file = "${path.module}/lambdas/manage_workstation_schedule/src/lambda_function.py"
  output_path = "${path.module}/lambdas/manage_workstation_schedule/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "manage_workstation_schedule" {
  function_name    = "${var.common.app_slug}_manage_workstation_schedule"
  filename         = data.archive_file.manage_workstation_schedule.output_path
  source_code_hash = data.archive_file.manage_workstation_schedule.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.manage_workstation_schedule]
  tags             = local.common_tags
}

data "archive_file" "manage_workstation_size" {
  type        = "zip"
  source_file = "${path.module}/lambdas/manage_workstation_size/src/lambda_function.py"
  output_path = "${path.module}/lambdas/manage_workstation_size/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "manage_workstation_size" {
  function_name    = "${var.common.app_slug}_manage_workstation_size"
  filename         = data.archive_file.manage_workstation_size.output_path
  source_code_hash = data.archive_file.manage_workstation_size.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.manage_workstation_size]
  tags             = local.common_tags
}

data "archive_file" "manage_workstation_volume" {
  type        = "zip"
  source_file = "${path.module}/lambdas/manage_workstation_volume/src/lambda_function.py"
  output_path = "${path.module}/lambdas/manage_workstation_volume/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "manage_workstation_volume" {
  function_name    = "${var.common.app_slug}_manage_workstation_volume"
  filename         = data.archive_file.manage_workstation_volume.output_path
  source_code_hash = data.archive_file.manage_workstation_volume.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.manage_workstation_volume]
  tags             = local.common_tags
}

data "archive_file" "perform_instance_action" {
  type        = "zip"
  source_file = "${path.module}/lambdas/perform_instance_action/src/lambda_function.py"
  output_path = "${path.module}/lambdas/perform_instance_action/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "perform_instance_action" {
  function_name    = "${var.common.app_slug}_perform_instance_action"
  filename         = data.archive_file.perform_instance_action.output_path
  source_code_hash = data.archive_file.perform_instance_action.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.perform_instance_action]
  tags             = local.common_tags
}

data "archive_file" "persigned_url" {
  type        = "zip"
  source_file = "${path.module}/lambdas/persigned_url/src/lambda_function.py"
  output_path = "${path.module}/lambdas/persigned_url/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "persigned_url" {
  function_name    = "${var.common.app_slug}_persigned_url"
  filename         = data.archive_file.persigned_url.output_path
  source_code_hash = data.archive_file.persigned_url.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.persigned_url]
  tags             = local.common_tags
}

data "archive_file" "request_export" {
  type        = "zip"
  source_file = "${path.module}/lambdas/request_export/src/lambda_function.py"
  output_path = "${path.module}/lambdas/request_export/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "request_export" {
  function_name    = "${var.common.app_slug}_request_export"
  filename         = data.archive_file.request_export.output_path
  source_code_hash = data.archive_file.request_export.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.request_export]
  tags             = local.common_tags
}

data "archive_file" "s3_metadata" {
  type        = "zip"
  source_file = "${path.module}/lambdas/s3_metadata/src/lambda_function.py"
  output_path = "${path.module}/lambdas/s3_metadata/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "s3_metadata" {
  function_name    = "${var.common.app_slug}_s3_metadata"
  filename         = data.archive_file.s3_metadata.output_path
  source_code_hash = data.archive_file.s3_metadata.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.s3_metadata]
  tags             = local.common_tags
}

data "archive_file" "send_email" {
  type        = "zip"
  source_file = "${path.module}/lambdas/send_email/src/lambda_function.py"
  output_path = "${path.module}/lambdas/send_email/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "send_email" {
  function_name    = "${var.common.app_slug}_send_email"
  filename         = data.archive_file.send_email.output_path
  source_code_hash = data.archive_file.send_email.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.send_email]
  tags             = local.common_tags
}

data "archive_file" "update_autoexport_status" {
  type        = "zip"
  source_file = "${path.module}/lambdas/update_autoexport_status/src/lambda_function.py"
  output_path = "${path.module}/lambdas/update_autoexport_status/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "update_autoexport_status" {
  function_name    = "${var.common.app_slug}_update_autoexport_status"
  filename         = data.archive_file.update_autoexport_status.output_path
  source_code_hash = data.archive_file.update_autoexport_status.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.update_autoexport_status]
  tags             = local.common_tags
}

data "archive_file" "update_file_status" {
  type        = "zip"
  source_file = "${path.module}/lambdas/update_file_status/src/lambda_function.py"
  output_path = "${path.module}/lambdas/update_file_status/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "update_file_status" {
  function_name    = "${var.common.app_slug}_update_file_status"
  filename         = data.archive_file.update_file_status.output_path
  source_code_hash = data.archive_file.update_file_status.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.update_file_status]
  tags             = local.common_tags
}

data "archive_file" "update_trusted_status" {
  type        = "zip"
  source_file = "${path.module}/lambdas/update_trusted_status/src/lambda_function.py"
  output_path = "${path.module}/lambdas/update_trusted_status/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "update_trusted_status" {
  function_name    = "${var.common.app_slug}_update_trusted_status"
  filename         = data.archive_file.update_trusted_status.output_path
  source_code_hash = data.archive_file.update_trusted_status.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.update_trusted_status]
  tags             = local.common_tags
}

data "archive_file" "workstation_schedule" {
  type        = "zip"
  source_file = "${path.module}/lambdas/workstation_schedule/src/lambda_function.py"
  output_path = "${path.module}/lambdas/workstation_schedule/lambda_deployment_package.zip"
}

resource "aws_lambda_function" "workstation_schedule" {
  function_name    = "${var.common.app_slug}_workstation_schedule"
  filename         = data.archive_file.workstation_schedule.output_path
  source_code_hash = data.archive_file.workstation_schedule.output_base64sha256
  role             = aws_iam_role.webportal_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.12"
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
  depends_on       = [data.archive_file.workstation_schedule]
  tags             = local.common_tags
}
