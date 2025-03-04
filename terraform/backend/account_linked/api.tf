# === Resource ===
# === Method Request  -> Integration Request  ===
# === Method Response <- Integration Response ===
resource "aws_api_gateway_resource" "r" {
  rest_api_id = var.rest_api.id
  parent_id   = var.rest_api.root_resource_id
  path_part   = local.path_part
}

# === Resource -> Method ===
resource "aws_api_gateway_method" "m" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.r.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method" "om" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.r.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# === Resource -> Integration ===
resource "aws_api_gateway_integration" "i" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.r.id
  http_method             = aws_api_gateway_method.m.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = aws_lambda_function.account_linked.invoke_arn

}

resource "aws_api_gateway_integration" "oi" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.r.id
  http_method             = aws_api_gateway_method.om.http_method
  type                    = "MOCK"
  request_templates        = {
    "application/json" = "{\"statusCode\": 200}"
  }
  depends_on = [ aws_api_gateway_method.om ]
}

# === Resource -> Method -> Response ===
resource "aws_api_gateway_method_response" "mr" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.r.id
  http_method = aws_api_gateway_method.m.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "omr" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.r.id
  http_method = aws_api_gateway_method.om.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = true,
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true,
    "method.response.header.Access-Control-Expose-Headers" = true,
    "method.response.header.Access-Control-Max-Age" = true
  }
  response_models = {
    "application/json" = "Empty"
  }
  depends_on = [ aws_api_gateway_method.om ]
}

# === Resource -> Integration -> Response ===
resource "aws_api_gateway_integration_response" "oir" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.r.id
  http_method = aws_api_gateway_method.om.http_method
  status_code = aws_api_gateway_method_response.omr.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = "'true'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'",
    "method.response.header.Access-Control-Expose-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Access-Control-Allow-Origin'",
    "method.response.header.Access-Control-Max-Age" = "'600'"
  }
  depends_on = [ aws_api_gateway_method_response.omr ]
}
