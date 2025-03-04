variable "module_name" {}
variable "module_slug" {}
variable "common" {}
variable "backend" {}
variable "fqdn" {}
locals {
  common_tags = {
    "Module Slug" = var.module_slug
  }
}
