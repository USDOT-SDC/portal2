# API Resources
locals {
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
      }
    }
    export_request = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
      }
    }
    export_table = {
      http_method = "POST"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request

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
      }
    }
    get_user_info = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
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
      }
    }
    manage_workstation_schedule = {
      http_method = "GET"
      environment_variables = {
        TABLENAME_MANAGE_UPTIME       = local.tablename_manage_uptime
        TABLENAME_MANAGE_UPTIME_INDEX = local.tablename_manage_uptime_index
      }
    }
    manage_workstation_size = {
      http_method = "GET"
      environment_variables = {
        TABLENAME_MANAGE_USER       = local.tablename_manage_user
        TABLENAME_MANAGE_USER_INDEX = local.tablename_manage_user_index
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
      }
    }
    request_export = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
        RECEIVER                    = local.receiver_email
      }
    }
    s3_metadata = {
      http_method = "GET"
      environment_variables = {
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
      }
    }
    send_email = {
      http_method = "POST"
      environment_variables = {
        RECEIVER_EMAIL = local.receiver_email
      }
    }
    update_autoexport_status = {
      http_method = "GET"
      environment_variables = {
        RESTAPIID                   = aws_api_gateway_rest_api.portal.id
        AUTHORIZERID                = aws_api_gateway_authorizer.portal.id
        TABLENAME_USER_STACKS       = local.tablename_user_stacks
        TABLENAME_AVAILABLE_DATASET = local.tablename_available_dataset
        TABLENAME_TRUSTED_USERS     = local.tablename_trusted_users
        TABLENAME_AUTOEXPORT_USERS  = local.tablename_autoexport_users
      }
    }
    update_file_status = {
      http_method = "GET"
      environment_variables = {
        RECEIVER_EMAIL                = local.receiver_email
        TABLENAME_EXPORT_FILE_REQUEST = local.tablename_export_file_request
      }
    }
    update_trusted_status = {
      http_method = "GET"
      environment_variables = {
        RECEIVER_EMAIL = local.receiver_email
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
  runtime       = "python3.12"
  lambda_role   = aws_iam_role.portal_lambdas
  rest_api      = aws_api_gateway_rest_api.portal
  authorizer_id = aws_api_gateway_authorizer.portal.id
}
