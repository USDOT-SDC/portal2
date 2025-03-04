resource "aws_cognito_user_pool" "old" {
  name                       = "dev-sdc-dot-cognito-pool"
  auto_verified_attributes   = ["email"]
  sms_authentication_message = "Your authentication code is {####}. "

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "Role"
    required                 = false

    string_attribute_constraints {
      max_length = "2048"
      min_length = "1"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "rolename"
    required                 = false

    string_attribute_constraints {
      max_length = "256"
      min_length = "1"
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  mfa_configuration = "OFF"

  password_policy {
    minimum_length                   = 8
    password_history_size            = 0
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  tags = {
    "App Support" = "Jeff.Ussing.CTR"
    "Environment" = "dev"
    "Fed Owner"   = "Dan Morgan"
    "SourceRepo"  = "sdc-dot-cognito-account-sync"
  }
}
