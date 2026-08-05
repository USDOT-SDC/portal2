data "aws_secretsmanager_secret" "dot_piv" {
  name = "portal2/cognito/dot-piv"
}

data "aws_secretsmanager_secret_version" "dot_piv" {
  secret_id = data.aws_secretsmanager_secret.dot_piv.id
}

locals {
  dot_piv_secret        = jsondecode(data.aws_secretsmanager_secret_version.dot_piv.secret_string)
  dot_piv_client_id     = local.dot_piv_secret["client_id"]
  dot_piv_client_secret = local.dot_piv_secret["client_secret"]
}
