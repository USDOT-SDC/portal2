variable "module_name" {}
variable "module_slug" {}
variable "common" {}
variable "resource_slug" {}
variable "foo" {}
variable "rest_api" {}
variable "authorizer_id" {}
variable "runtime" {}
variable "lambda_role" {}
locals {
  common_tags = {
    "Module Slug" = "be-${var.module_slug}"
  }
}
