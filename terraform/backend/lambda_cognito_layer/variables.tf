variable "module_name" {}
variable "module_slug" {}
variable "common" {}
locals {
  tags = {
    module = "lambda_cognito_layer"
  }
}