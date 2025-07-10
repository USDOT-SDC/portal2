output "cognito" {
  value = {
    user_pool = {
      arn    = aws_cognito_user_pool.this.arn
      id     = aws_cognito_user_pool.this.id
      domain = aws_cognito_user_pool_domain.this.domain
      # domain = "${aws_cognito_user_pool_domain.this.domain}.auth.${var.common.region}.amazoncognito.com"
      endpoint = aws_cognito_user_pool.this.endpoint
      client = {
        id                   = aws_cognito_user_pool_client.this.id
        allowed_oauth_scopes = aws_cognito_user_pool_client.this.allowed_oauth_scopes
      }
    }
  }
}
