resource "aws_cognito_user_pool_client" "old_login_gov" {
  name         = "dev-private-login-gov-app-client"
  user_pool_id = aws_cognito_user_pool.old.id
  allowed_oauth_flows = [
    "code",
    "implicit",
  ]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "email",
    "openid",
    "profile",
  ]
  auth_session_validity = 3
  callback_urls = [
    "http://localhost:4200/index.html",
    "http://localhost:8000/index.html",
    "https://d11mc6mwhsvxkx.cloudfront.net/index.html",
    "https://dev-portal-ecs-sdc.dot.gov/index.html",
    "https://internal-dev-nginx-load-balancer-429520900.us-east-1.elb.amazonaws.com/index.html",
    "https://portal.sdc-dev.dot.gov/index.html",
  ]
  default_redirect_uri                          = null
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = false
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  logout_urls = [
    "http://localhost:8000/index.html",
    "https://dev-portal-ecs-sdc.dot.gov/index.html",
  ]
  prevent_user_existence_errors = "LEGACY"
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
  refresh_token_validity = 30
  supported_identity_providers = [
    "dev-pvt-login-gov-lambda-proxy",
  ]
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
}

resource "aws_cognito_user_pool_client" "old_active_directory" {
  name         = "dev-dot-active-directory-app-client"
  user_pool_id = aws_cognito_user_pool.old.id
  allowed_oauth_flows = [
    "code",
    "implicit",
  ]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "email",
    "openid",
    "profile",
  ]
  auth_session_validity = 3
  callback_urls = [
    "http://localhost:4200/dashboard",
    "http://localhost:4200/index.html",
    "http://localhost:4200/login/redirect",
    "http://localhost:8000/index.html",
    "https://d11mc6mwhsvxkx.cloudfront.net/index.html",
    "https://dev-portal-ecs-sdc.dot.gov/index.html",
    "https://internal-dev-nginx-load-balancer-429520900.us-east-1.elb.amazonaws.com/index.html",
    "https://portal.sdc-dev.dot.gov/index.html",
    "https://sub1.sdc-dev.dot.gov/dashboard",
    "https://sub1.sdc-dev.dot.gov/login/redirect",
  ]
  default_redirect_uri                          = null
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = false
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  logout_urls = [
    "http://localhost:8000/index.html",
    "https://dev-portal-ecs-sdc.dot.gov/index.html",
  ]
  prevent_user_existence_errors = "LEGACY"
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
  refresh_token_validity = 30
  supported_identity_providers = [
    "dev-dot-ad",
  ]
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
}

resource "aws_cognito_user_pool_client" "old_sdc_dot" {
  name                  = "dev-sdc-dot-app-client"
  user_pool_id          = aws_cognito_user_pool.old.id
  allowed_oauth_flows = [
    "code",
    "implicit",
  ]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_scopes = [
    "email",
    "openid",
    "phone",
    "profile",
  ]
  auth_session_validity = 3
  callback_urls = [
    "http://localhost:4200/index.html",
    "http://localhost:8000/index.html",
    "https://d11mc6mwhsvxkx.cloudfront.net/index.html",
    "https://dev-portal-ecs-sdc.dot.gov/index.html",
    "https://internal-dev-nginx-load-balancer-429520900.us-east-1.elb.amazonaws.com/index.html",
    "https://portal.sdc-dev.dot.gov/index.html",
  ]
  default_redirect_uri                          = null
  enable_propagate_additional_user_context_data = false
  enable_token_revocation                       = false
  explicit_auth_flows = [
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  logout_urls = [
    "http://localhost:8000/index.html",
    "https://dev-portal-ecs-sdc.dot.gov/index.html",
  ]
  prevent_user_existence_errors = "LEGACY"
  read_attributes = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
  refresh_token_validity = 30
  supported_identity_providers = [
    "USDOT-ADFS",
  ]
  write_attributes = [
    "address",
    "birthdate",
    "email",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "picture",
    "preferred_username",
    "profile",
    "updated_at",
    "website",
    "zoneinfo",
  ]
}
