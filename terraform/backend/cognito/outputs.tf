output "cognito" {
  value = {
    user_pool = {
      id     = aws_cognito_user_pool.this.id
      domain = "${aws_cognito_user_pool_domain.this.domain}.auth.${var.common.region}.amazoncognito.com"
      client = {
        id                   = aws_cognito_user_pool_client.this.id
        allowed_oauth_scopes = aws_cognito_user_pool_client.this.allowed_oauth_scopes
      }
    }
  }
}
