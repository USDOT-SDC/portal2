variable "module_name" {}
variable "module_slug" {}
variable "common" {}
variable "rest_api" {}
variable "authorizer_id" {}
variable "lambda_role" {}
variable "lambda_cognito_layer" {}
variable "env_vars" {}

locals {
  path_part = "reset_temporary_password"
  common_tags = {
    "Module Slug" = "be-${var.module_slug}"
  }
}
