# === Resource ===
resource "aws_api_gateway_resource" "this" {
  rest_api_id = var.rest_api_portal.id
  parent_id   = var.rest_api_portal.root_resource_id
  path_part   = var.foo.path_part
}

# === Resource -> Method -> Request ===
resource "aws_api_gateway_method" "this" {
  rest_api_id   = var.rest_api_portal.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = "ANY"
  authorization = "NONE"
}

# === Resource -> Integration -> Request ===
resource "aws_api_gateway_integration" "this" {
  rest_api_id          = var.rest_api_portal.id
  resource_id          = aws_api_gateway_resource.this.id
  http_method          = aws_api_gateway_method.this.http_method
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

# === Resource -> Integration -> Response ===
resource "aws_api_gateway_integration_response" "this" {
  rest_api_id = var.rest_api_portal.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = aws_api_gateway_method_response.this.status_code

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
resource "aws_api_gateway_method_response" "this" {
  rest_api_id = var.rest_api_portal.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.this.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}
