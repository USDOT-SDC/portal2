# === Resource ===
resource "aws_api_gateway_resource" "r" {
  rest_api_id = var.foo.rest_api.id
  parent_id   = var.foo.rest_api.root_resource_id
  path_part   = var.foo.path_part
}

# === Resource -> Method ===
resource "aws_api_gateway_method" "m" {
  for_each      = var.foo.methods
  rest_api_id   = var.foo.rest_api.id
  resource_id   = aws_api_gateway_resource.r.id
  http_method   = each.value.http_method
  authorization = each.value.authorization
  authorizer_id = each.value.authorizer.id
}

# === Resource -> Integration ===
resource "aws_api_gateway_integration" "i" {
  for_each    = var.foo.methods
  rest_api_id = var.foo.rest_api.id
  resource_id = aws_api_gateway_resource.r.id
  http_method = aws_api_gateway_method.m[each.key].http_method
  type        = "AWS_PROXY"
  # timeout_milliseconds = 1000
  # request_templates = {
  #   "application/json" = jsonencode(
  #     {
  #       "statusCode" : 200
  #     }
  #   )
  # }
}

# === Resource -> Integration -> Response ===
resource "aws_api_gateway_integration_response" "ir" {
  for_each    = var.foo.methods
  rest_api_id = var.foo.rest_api.id
  resource_id = aws_api_gateway_resource.r.id
  http_method = aws_api_gateway_method.m[each.key].http_method
  status_code = aws_api_gateway_method_response.mr[each.key].status_code

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
resource "aws_api_gateway_method_response" "mr" {
  for_each    = var.foo.methods
  rest_api_id = var.foo.rest_api.id
  resource_id = aws_api_gateway_resource.r.id
  http_method = aws_api_gateway_method.m[each.key].http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}
