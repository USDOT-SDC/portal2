# === Resource ===
# === Method Request  -> Integration Request  ===
# === Method Response <- Integration Response ===
resource "aws_api_gateway_resource" "ddb_crud" {
  rest_api_id = var.rest_api.id
  parent_id   = var.rest_api.root_resource_id
  path_part   = local.path_part
}

# === Resource -> Methods ===
resource "aws_api_gateway_method" "options" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.ddb_crud.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.ddb_crud.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.ddb_crud.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method" "put" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.ddb_crud.id
  http_method   = "PUT"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

resource "aws_api_gateway_method" "delete" {
  rest_api_id   = var.rest_api.id
  resource_id   = aws_api_gateway_resource.ddb_crud.id
  http_method   = "DELETE"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = var.authorizer_id
}

# === Resource -> Integrations ===
resource "aws_api_gateway_integration" "options" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.ddb_crud.id
  http_method             = aws_api_gateway_method.options.http_method
  type                    = "MOCK"
  request_templates        = {
    "application/json" = "{\"statusCode\": 200}"
  }
  depends_on = [ aws_api_gateway_method.options ]
}

resource "aws_api_gateway_integration" "post" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.ddb_crud.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = aws_lambda_function.ddb_crud.invoke_arn
}

resource "aws_api_gateway_integration" "get" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.ddb_crud.id
  http_method             = aws_api_gateway_method.get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = aws_lambda_function.ddb_crud.invoke_arn
}

resource "aws_api_gateway_integration" "put" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.ddb_crud.id
  http_method             = aws_api_gateway_method.put.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = aws_lambda_function.ddb_crud.invoke_arn
}

resource "aws_api_gateway_integration" "delete" {
  rest_api_id             = var.rest_api.id
  resource_id             = aws_api_gateway_resource.ddb_crud.id
  http_method             = aws_api_gateway_method.delete.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = aws_lambda_function.ddb_crud.invoke_arn
}

# === Resource -> Method -> Responses ===
resource "aws_api_gateway_method_response" "options" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.ddb_crud.id
  http_method = aws_api_gateway_method.options.http_method
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
  depends_on = [ aws_api_gateway_method.options ]
}

resource "aws_api_gateway_method_response" "post" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.ddb_crud.id
  http_method = aws_api_gateway_method.post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "get" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.ddb_crud.id
  http_method = aws_api_gateway_method.get.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "put" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.ddb_crud.id
  http_method = aws_api_gateway_method.put.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_method_response" "delete" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.ddb_crud.id
  http_method = aws_api_gateway_method.delete.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

# === Resource -> Integration -> Response ===
resource "aws_api_gateway_integration_response" "options" {
  rest_api_id = var.rest_api.id
  resource_id = aws_api_gateway_resource.ddb_crud.id
  http_method = aws_api_gateway_method.options.http_method
  status_code = aws_api_gateway_method_response.options.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = "'true'",
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'",
    "method.response.header.Access-Control-Expose-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,Access-Control-Allow-Origin'",
    "method.response.header.Access-Control-Max-Age" = "'600'"
  }
  depends_on = [ aws_api_gateway_method_response.options ]
}
