# API Resources
locals {
  api_resources = {
    hello_world = {
      http_method = "ANY"
      environment_variables = {}
    }
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
