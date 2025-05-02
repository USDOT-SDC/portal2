resource "aws_cognito_user_pool" "this" {
  name = var.user_pool_name

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    # recovery_mechanism {
    #   name     = "verified_phone_number"
    #   priority = 2
    # }
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
    invite_message_template {
      email_subject = "Your Secure Data Commons' temporary password"
      email_message = "Your Secure Data Commons' username is {username} and temporary password is {####}."
      sms_message   = "Your Secure Data Commons' username is {username} and temporary password is {####}"
    }
  }

  auto_verified_attributes = ["email"]

  device_configuration {
    challenge_required_on_new_device      = true
    device_only_remembered_on_user_prompt = true
  }

  email_configuration {
    # email_sending_account = "COGNITO_DEFAULT"
    email_sending_account = "DEVELOPER"
    # configuration_set      = ""
    from_email_address     = data.aws_sesv2_email_identity.sdc_support.email_identity
    reply_to_email_address = data.aws_sesv2_email_identity.sdc_support.email_identity
    source_arn             = data.aws_sesv2_email_identity.sdc_support.arn
  }

  mfa_configuration = var.mfa_enabled ? "ON" : "OFF"

  password_policy {
    minimum_length                   = 12
    password_history_size            = 12
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 3
  }

  # sms_authentication_message = var.sms_authentication_message

  # sms_configuration {
  #   external_id    = local.external_id
  #   sns_caller_arn = aws_iam_role.this.arn
  #   sns_region     = var.common.region
  # }

  software_token_mfa_configuration {
    enabled = true
  }

  user_pool_add_ons {
    advanced_security_mode = "ENFORCED"
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    # default_email_option = "CONFIRM_WITH_CODE"
    default_email_option  = "CONFIRM_WITH_LINK"
    email_message         = var.verification_message_template.email_message
    email_message_by_link = var.verification_message_template.email_message_by_link
    email_subject         = var.verification_message_template.email_subject
    email_subject_by_link = var.verification_message_template.email_subject_by_link
    # sms_message           = var.verification_message_template.sms_message
  }

  tags = local.common_tags
}

resource "aws_cognito_user_pool_client" "this" {
  name         = var.user_pool_name
  user_pool_id = aws_cognito_user_pool.this.id

  access_token_validity = 1 # default unit is hours

  allowed_oauth_flows_user_pool_client = true

  allowed_oauth_flows = [
    "code",
    "implicit",
    # "client_credentials",
  ]

  allowed_oauth_scopes = [
    "email",
    "openid",
    "phone",
    "profile",
  ]

  auth_session_validity = 3 # in minutes

  callback_urls = [
    "http://localhost:4200/dashboard",
    "http://localhost:4200/login/redirect",
    "http://localhost:5000",
    "http://localhost:5000/authorize",
    "https://sub1.${var.fqdn}/dashboard",
    "https://sub1.${var.fqdn}/login/redirect",
    "https://portal.${var.fqdn}/dashboard",
    "https://portal.${var.fqdn}/login/redirect",
    "https://guacamole.${var.fqdn}/guacamole",
  ]

  # default_redirect_uri = ""

  enable_token_revocation = true

  explicit_auth_flows = [
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    # "ADMIN_NO_SRP_AUTH",
    # "CUSTOM_AUTH_FLOW_ONLY",
    # "USER_PASSWORD_AUTH",
    # "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    # "ALLOW_USER_PASSWORD_AUTH",
  ]

  generate_secret = false

  id_token_validity = 1 # default unit is hours

  logout_urls = [
    "http://localhost:4200/index.html",
    "http://localhost:5000/index.html",
    "https://sub1.${var.fqdn}/index.html",
    "https://portal.${var.fqdn}/index.html",
    "https://guacamole.${var.fqdn}/guacamole"
  ]

  refresh_token_validity = 30 # default unit is days

  # supported_identity_providers = ["COGNITO"]
  supported_identity_providers = ["COGNITO", "DOT-PIV"]
  depends_on                   = [aws_cognito_identity_provider.dot_piv]
}

locals {
  client_id_dev  = "8bb2d24b-2e18-451a-8a5a-34f0ef3caaba"
  client_id_prod = "9cfb5e72-7b26-4b73-a19d-d592c95acd72"
  client_id      = var.common.environment == "dev" ? local.client_id_dev : local.client_id_prod
}

resource "aws_cognito_identity_provider" "dot_piv" {
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "DOT-PIV"
  provider_type = "OIDC"
  attribute_mapping = {
    email                    = "email"
    family_name              = "family_name"
    given_name               = "given_name"
    name                     = "name"               # Last, First (Mode)
    preferred_username       = "preferred_username" # email
    profile                  = "profile"
  }
  # idp_identifiers = []
  provider_details = {
    # https://login.microsoftonline.com/c4cd245b-44f0-4395-a1aa-3848d258f78b/v2.0/.well-known/openid-configuration
    client_id                     = "8bb2d24b-2e18-451a-8a5a-34f0ef3caaba"
    client_secret                 = var.common.client_secret
    authorize_scopes              = "email openid profile offline_access"
    attributes_request_method     = "GET"
    oidc_issuer                   = "https://login.microsoftonline.com/c4cd245b-44f0-4395-a1aa-3848d258f78b/v2.0"
    attributes_url                = "https://graph.microsoft.com/oidc/userinfo"
    # attributes_url_add_attributes = true
    authorize_url                 = "https://login.microsoftonline.com/c4cd245b-44f0-4395-a1aa-3848d258f78b/oauth2/v2.0/authorize"
    jwks_uri                      = "https://login.microsoftonline.com/c4cd245b-44f0-4395-a1aa-3848d258f78b/discovery/v2.0/keys"
    token_url                     = "https://login.microsoftonline.com/c4cd245b-44f0-4395-a1aa-3848d258f78b/oauth2/v2.0/token"
  }
}

resource "aws_cognito_user_pool_domain" "this" {
  domain = "usdot-sdc-${var.common.environment}"
  # certificate_arn = var.common.certificates.external.arn
  user_pool_id = aws_cognito_user_pool.this.id
}

data "aws_sesv2_email_identity" "sdc_support" {
  email_identity = "sdc-support@dot.gov"
}
