# API Resources
locals {
  allow_origin_url = "*"
  # allow_origin_url = "https://${aws_route53_record.sub1.name}" # update to aws_route53_record.portal.name when ready to cut over
  api_resources = {
    data_dictionary = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    desired_instance_types = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    download_url = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    export_objects = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    export_request = {
      http_method = "POST"
      environment_variables = {
        RESTAPIID                     = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                  = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET   = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS       = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS    = local.tablename_autoexport_users
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
        ALLOW_ORIGIN_URL              = local.allow_origin_url
      }
    }
    export_table = {
      http_method = "POST"
      environment_variables = {
        RESTAPIID                     = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                  = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET   = local.tablename_available_dataset
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
        ALLOW_ORIGIN_URL              = local.allow_origin_url
      }
    }
    get_health = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    get_user_info = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        HASH_KEY_USER_STACKS        = "username"
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    hello_world = {
      http_method           = "ANY"
      environment_variables = {}
    }
    instance_status = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    manage_workstation_schedule = {
      http_method = "GET"
      environment_variables = {
        TABLENAME_MANAGE_UPTIME       = local.tablename_manage_uptime
        TABLENAME_MANAGE_UPTIME_INDEX = local.tablename_manage_uptime_index
        ALLOW_ORIGIN_URL              = local.allow_origin_url
      }
    }
    manage_workstation_size = {
      http_method = "GET"
      environment_variables = {
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_MANAGE_USER       = local.tablename_manage_user
        TABLENAME_MANAGE_USER_INDEX = local.tablename_manage_user_index
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
      timeout = 300
    }
    manage_workstation_volume = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    perform_instance_action = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    presigned_url = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    request_export = {
      http_method = "POST"
      environment_variables = {
        RESTAPIID                     = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                  = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS         = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET   = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS       = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS    = local.tablename_autoexport_users
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
        RECEIVER_EMAIL                = local.receiver_email
        ALLOW_ORIGIN_URL              = local.allow_origin_url
      }
    }
    s3_metadata = {
      http_method = "GET"
      memory_size = 160
      environment_variables = {
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
        ALLOW_ORIGIN_URL              = local.allow_origin_url
      }
    }
    send_email = {
      http_method = "POST"
      environment_variables = {
        RECEIVER_EMAIL   = local.receiver_email
        ALLOW_ORIGIN_URL = local.allow_origin_url
      }
    }
    update_autoexport_status = {
      http_method = "POST"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        ALLOW_ORIGIN_URL            = local.allow_origin_url
      }
    }
    update_file_status = {
      http_method = "POST"
      environment_variables = {
        RECEIVER_EMAIL                = local.receiver_email
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
        ALLOW_ORIGIN_URL              = local.allow_origin_url
      }
    }
    update_trusted_status = {
      http_method = "POST"
      environment_variables = {
        RECEIVER_EMAIL          = local.receiver_email
        TABLENAME_TRUSTED_USERS = local.tablename_trusted_users
        ALLOW_ORIGIN_URL        = local.allow_origin_url
      }
    }
    workstation_schedule = {
      http_method = "GET"
      environment_variables = {
        TABLENAME_MANAGE_DISK         = local.tablename_manage_disk
        TABLENAME_MANAGE_DISK_INDEX   = local.tablename_manage_disk_index
        TABLENAME_MANAGE_UPTIME       = local.tablename_manage_uptime
        TABLENAME_MANAGE_UPTIME_INDEX = local.tablename_manage_uptime_index
        TABLENAME_MANAGE_USER         = local.tablename_manage_user
        TABLENAME_MANAGE_USER_INDEX   = local.tablename_manage_user_index
        ALLOW_ORIGIN_URL              = local.allow_origin_url
      }
    }
  }
}

module "api" {
  for_each      = local.api_resources
  module_name   = "API, ${each.key}"
  module_slug   = "api-${each.key}"
  source        = "./api_resource"
  common        = var.common
  resource_slug = each.key
  foo           = each.value
  runtime       = "python3.13"
  lambda_role   = aws_iam_role.portal_lambdas
  rest_api      = aws_api_gateway_rest_api.portal
  authorizer_id = aws_api_gateway_authorizer.portal.id
}

module "cognito" {
  module_name                  = "Cognito"
  module_slug                  = "cognito"
  source                       = "./cognito"
  common                       = var.common
  user_pool_name               = "portal"
  mfa_enabled                  = true
  sms_authentication_message   = "Your authentication code is {####}."
  email_authentication_message = "Your authentication code is {####}."
  verification_message_template = {
    email_message         = "Your verification code is {####}."
    email_message_by_link = "{##Click Here##} to verify."
    email_subject         = "Verify your email"
    email_subject_by_link = "Verify your email"
    sms_message           = "Your verification code is {####}."
  }
  fqdn = var.fqdn
}

module "ddb_crud" {
  module_name   = "API, DynamoDB CRUD"
  module_slug   = "api-ddb-crud"
  source        = "./ddb_crud"
  common        = var.common
  rest_api      = aws_api_gateway_rest_api.portal
  authorizer_id = aws_api_gateway_authorizer.portal.id
}

module "lambda_cognito_layer" {
  module_name = "Lambda Layer, lambda_cognito_layer"
  module_slug = "layer-lambda-cognito-layer"
  source      = "./lambda_cognito_layer"
  common      = var.common
}

module "guacamole" {
  module_name  = "Server, Guacamole"
  module_slug  = "guacamole"
  source       = "./guacamole"
  common       = var.common
  certificates = var.certificates
  cognito      = module.cognito.cognito
  fqdn         = var.fqdn
  # TODO switch these for finial deployment
  # portal_url   = aws_route53_record.portal.name
  portal_url = aws_route53_record.sub1.name
}
