variable "module_name" {}
variable "module_slug" {}
variable "common" {}
variable "rest_api" {}
variable "authorizer_id" {}
variable "lambda_role" {}
variable "lambda_cognito_layer" {}
variable "environment_variables" {}

locals {
  path_part = "account_linked"
  common_tags = {
    "Module Slug" = "be-${var.module_slug}"
  }
  environment_variables = {
    AWS_REGION    = var.common.region
  }
}
