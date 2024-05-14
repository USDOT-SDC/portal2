# API Resources
locals {
  api_resources = {
    data_dictionary = {
      path_part            = "data_dictionary"
      http_method          = "ANY"
      authorization        = "NONE"
      type                 = "MOCK"
      timeout_milliseconds = 1000
      request_templates = {
        "application/json" = jsonencode(
          {
            "statusCode" : 200
          }
        )
      }
      response_templates = {
        "application/json" = jsonencode(
          {
            "isHealthy" : true,
            "source" : "portal"
          }
        )
      }
      method_response_status_code = "200"
      response_models = {
        "application/json" = "Empty"
      }
    }
  }
}
module "api_resource" {
  for_each        = local.api_resources
  module_name     = "API Resource, ${each.key}"
  module_slug     = "api-resource_${each.key}"
  source          = "./api_resource"
  common          = var.common
  rest_api_portal = aws_api_gateway_rest_api.portal
  foo             = each.value
}
