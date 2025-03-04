# === REST API ===
resource "aws_api_gateway_rest_api" "portal" {
  name        = "portal"
  description = "Portal 2 Backend"
  tags        = local.common_tags
}

# === REST API Authorizer ===
resource "aws_api_gateway_authorizer" "portal" {
  name          = "PortalCognitoUserPoolAuthorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = aws_api_gateway_rest_api.portal.id
  provider_arns = [module.cognito.cognito.user_pool.arn]
}

# === REST API Domain Name ===
resource "aws_api_gateway_domain_name" "portal_api" {
  domain_name     = "portal-api.${var.fqdn}"
  certificate_arn = var.certificates.external.arn
}

resource "aws_api_gateway_domain_name" "sub2" {
  domain_name     = "sub2.${var.fqdn}"
  certificate_arn = var.certificates.external.arn
}

# === REST API Domain Name Mapping ===
resource "aws_api_gateway_base_path_mapping" "portal_api" {
  api_id      = aws_api_gateway_rest_api.portal.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  domain_name = aws_api_gateway_domain_name.portal_api.domain_name
  base_path   = "v1"
}

resource "aws_api_gateway_base_path_mapping" "sub2" {
  api_id      = aws_api_gateway_rest_api.portal.id
  stage_name  = aws_api_gateway_stage.v1.stage_name
  domain_name = aws_api_gateway_domain_name.sub2.domain_name
  base_path   = "v1"
}

# === REST API Stage ===
resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.portal.id
  rest_api_id   = aws_api_gateway_rest_api.portal.id
  stage_name    = "v1"
  tags          = local.common_tags
}

# The health resource is an example of the Terraform resources
# necessary to build a complete API resource integration.
# === Resource ===
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.portal.id
  parent_id   = aws_api_gateway_rest_api.portal.root_resource_id
  path_part   = "health"
}

# === Resource -> Method ===
# === Resource -> Method -> Request ===
resource "aws_api_gateway_method" "health_any" {
  rest_api_id   = aws_api_gateway_rest_api.portal.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "ANY"
  authorization = "NONE"
}

# === Resource -> Method -> Integration -> Request ===
resource "aws_api_gateway_integration" "health_any_mock" {
  rest_api_id          = aws_api_gateway_rest_api.portal.id
  resource_id          = aws_api_gateway_resource.health.id
  http_method          = aws_api_gateway_method.health_any.http_method
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

# === Resource -> Method -> Integration -> Response ===
resource "aws_api_gateway_integration_response" "health_any_200" {
  rest_api_id = aws_api_gateway_rest_api.portal.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_any.http_method
  status_code = aws_api_gateway_method_response.health_any_200.status_code

  response_templates = {
    "application/json" = jsonencode(
      {
        "isHealthy" : true,
        "source" : "portal"
      }
    )
  }
}

# === Resource -> Method -> Response ===
resource "aws_api_gateway_method_response" "health_any_200" {
  rest_api_id = aws_api_gateway_rest_api.portal.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_any.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

# === REST API Deployment ===
# build the deployment_hash_maps used to trigger redeployments
locals {
  # api_gateway_deployment_list = module.api["hello_world"].deployment_hash
  modules_deployment_hash_map = { for k, v in local.api_resources : k => module.api[k].deployment_hash }
  other_deployment_hash_map = {
    account_linked           = module.account_linked.deployment_hash
    ddb_crud                 = module.ddb_crud.deployment_hash
    link_account             = module.link_account.deployment_hash
    reset_temporary_password = module.reset_temporary_password.deployment_hash
    health = sha1(
      jsonencode(
        {
          r  = aws_api_gateway_resource.health,
          m  = aws_api_gateway_method.health_any,
          i  = aws_api_gateway_integration.health_any_mock,
          ir = aws_api_gateway_integration_response.health_any_200,
          mr = aws_api_gateway_method_response.health_any_200,
        }
      )
    )
  }
  api_gateway_deployment_hash_map = merge(
    local.modules_deployment_hash_map,
    local.other_deployment_hash_map
  )
}
# To properly capture all REST API configuration in a deployment, 
# this resource must have triggers on all prior Terraform resources 
# that manage resources/paths, methods, integrations, etc.
resource "aws_api_gateway_deployment" "portal" {
  rest_api_id = aws_api_gateway_rest_api.portal.id
  triggers = {
    redeployment = sha1(jsonencode(local.api_gateway_deployment_hash_map))
    # redeployment = sha1(timestamp())
  }
  lifecycle {
    create_before_destroy = true
  }
}
