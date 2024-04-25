resource "aws_api_gateway_rest_api" "portal" {
  name = "portal"
  tags = local.common_tags
}

resource "aws_api_gateway_resource" "portal" {
  parent_id   = aws_api_gateway_rest_api.portal.root_resource_id
  path_part   = "portal"
  rest_api_id = aws_api_gateway_rest_api.portal.id
}

resource "aws_api_gateway_method" "portal_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.portal.id
  rest_api_id   = aws_api_gateway_rest_api.portal.id
}

resource "aws_api_gateway_integration" "portal_get" {
  http_method = aws_api_gateway_method.portal_get.http_method
  resource_id = aws_api_gateway_resource.portal.id
  rest_api_id = aws_api_gateway_rest_api.portal.id
  type        = "MOCK"
}

resource "aws_api_gateway_deployment" "portal" {
  rest_api_id = aws_api_gateway_rest_api.portal.id
  triggers = {
    # redeployment = filesha1("${path.module}/api.tf")
    # NOTE: The configuration below will satisfy ordering considerations,
    #       but not pick up all future REST API changes. More advanced patterns
    #       are possible, such as using the filesha1() function against the
    #       Terraform configuration file(s) or removing the .id references to
    #       calculate a hash against whole resources. Be aware that using whole
    #       resources will show a difference after the initial implementation.
    #       It will stabilize to only change when resources change afterwards.
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.portal.id,
      aws_api_gateway_method.portal_get.id,
      aws_api_gateway_integration.portal_get.id,
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "v1" {
  deployment_id = aws_api_gateway_deployment.portal.id
  rest_api_id   = aws_api_gateway_rest_api.portal.id
  stage_name    = "v1"
  tags          = local.common_tags
}
