variable "module_name" {}
variable "module_slug" {}
variable "common" {}
variable "fqdn" {}
locals {
  external_id = "DesperateZebraFlops" # just a random string
  common_tags = {
    "Module Slug" = "be-${var.module_slug}"
  }
}

variable "user_pool_name" {
  type        = string
  description = "Name of the Cognito User Pool"
}

variable "mfa_enabled" {
  type        = bool
  description = "Enable MFA for the user pool"
  default     = false
}

variable "sms_authentication_message" {
  type        = string
  description = "Message for SMS-based authentication"
  default     = "Your authentication code is {####}."
}

variable "email_authentication_message" {
  type        = string
  description = "Message for email-based authentication"
  default     = "Your authentication code is {####}."
}

variable "verification_message_template" {
  type = object({
    email_message         = string
    email_message_by_link = string
    email_subject         = string
    email_subject_by_link = string
    sms_message           = string
  })
  description = "Template for verification messages"
}
