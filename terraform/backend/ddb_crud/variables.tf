variable "module_name" {}
variable "module_slug" {}
variable "common" {}
variable "rest_api" {}
variable "authorizer_id" {}
locals {
  path_part = "ddb_crud"
  common_tags = {
    "Module Slug" = "be-${var.module_slug}"
  }
}
