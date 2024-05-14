# API Resources
locals {
  api_resources = {
    data_dictionary = {
      rest_api  = aws_api_gateway_rest_api.portal
      path_part = "data_dictionary"
      methods = {
        get = {
          http_method   = "GET"
          authorization = "COGNITO_USER_POOLS"
          authorizer    = aws_api_gateway_authorizer.portal
          integration = {
            type = "AWS_PROXY"
            request_templates = {
              "application/json" = jsonencode(
                {
                  "statusCode" : 200
                }
              )
            }
          }
          integration_response = {
            response_templates = {
              "application/json" = jsonencode(
                {
                  "isHealthy" : true,
                  "source" : "portal"
                }
              )
            }
          }
          method_response = {
            method_response_status_code = "200"
            response_models = {
              "application/json" = "Empty"
            }
          }
        }
        options = {
          http_method   = "OPTIONS"
          authorization = "NONE"
          authorizer    = { id = "" }
          integration = {
            type                 = "MOCK"
            timeout_milliseconds = 1000
            request_templates = {
              "application/json" = jsonencode(
                {
                  "statusCode" : 200
                }
              )
            }
          }
          integration_response = {
            response_templates = {
              "application/json" = jsonencode(
                {
                  "isHealthy" : true,
                  "source" : "portal"
                }
              )
            }
          }
          method_response = {
            method_response_status_code = "200"
            response_models = {
              "application/json" = "Empty"
            }
          }
        }
      }
    }
  }
}

module "api" {
  for_each    = local.api_resources
  module_name = "API, ${each.key}"
  module_slug = "api-${each.key}"
  source      = "./api_resource"
  common      = var.common
  foo         = each.value
}
