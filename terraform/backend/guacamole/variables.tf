variable "module_name" {}
variable "module_slug" {}
variable "common" {}
variable "certificates" {}
variable "cognito" {}
variable "fqdn" {}
locals {
  tags = {
    module = "be-${var.module_slug}"
  }
}