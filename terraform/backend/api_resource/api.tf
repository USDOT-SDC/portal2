# === Resource ===
# === Method Request  -> Integration Request  ===
# === Method Response <- Integration Response ===
resource "aws_api_gateway_resource" "r" {
  rest_api_id = var.rest_api.id
  parent_id   = var.rest_api.root_resource_id
  path_part   = var.resource_slug
}

# === Resource -> Method ===
resource "aws_api_gateway_method" "m" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.r.id
  http_method   = var.foo.http_method
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

# === Resource -> Integration ===
resource "aws_api_gateway_integration" "i" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.r.id
  http_method             = aws_api_gateway_method.m.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = aws_lambda_function.f.invoke_arn

}

# === Resource -> Integration -> Response ===
# resource "aws_api_gateway_integration_response" "ir" {
#   rest_api_id = var.rest_api.id
#   resource_id = aws_api_gateway_resource.r.id
#   http_method = aws_api_gateway_method.m.http_method
#   status_code = aws_api_gateway_method_response.mr.status_code
# }

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
