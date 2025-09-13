resource "aws_dynamodb_table" "login_attempts" {
  name         = "portal_login_attempts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "username"

  attribute {
    name = "username"
    type = "S"
  }
}
