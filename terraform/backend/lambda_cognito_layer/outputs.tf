# use caution when making changes to outputs
# outputs are in the tfstate and may be used by other configurations
output "lambda_cognito_layer" {
  value = aws_lambda_layer_version.lambda_cognito_layer
}