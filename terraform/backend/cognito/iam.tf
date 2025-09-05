# === Pre-sign Up ===
resource "aws_iam_role" "pre_sign_up_lambda" {
  name = "${var.user_pool_name}_pre_sign_up_lambda"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        }
      ]
    }
  )
  tags = local.common_tags
}


resource "aws_iam_role_policy" "pre_sign_up_lambda_allow_logging" {
  name = "allow_logging"
  role = aws_iam_role.pre_sign_up_lambda.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
          ]
          Resource = "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "pre_sign_up_lambda_allow_cognito" {
  name = "allow_cognito"
  role = aws_iam_role.pre_sign_up_lambda.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "cognito-idp:ListUsers",
            "cognito-idp:AdminLinkProviderForUser",
            "cognito-idp:AdminUpdateUserAttributes"
          ]
          Resource = aws_cognito_user_pool.this.arn
        }
      ]
    }
  )
}

resource "aws_iam_role_policies_exclusive" "pre_sign_up_lambda" {
  role_name = aws_iam_role.pre_sign_up_lambda.name
  policy_names = [
    aws_iam_role_policy.pre_sign_up_lambda_allow_logging.name,
    aws_iam_role_policy.pre_sign_up_lambda_allow_cognito.name
  ]
}

# === Pre-auth Up ===
resource "aws_iam_role" "pre_auth_lambda" {
  name = "${var.user_pool_name}_pre_auth_lambda"
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = "sts:AssumeRole"
          Effect = "Allow"
          Principal = {
            Service = "lambda.amazonaws.com"
          }
        }
      ]
    }
  )
  tags = local.common_tags
}


resource "aws_iam_role_policy" "pre_auth_lambda_allow_logging" {
  name = "allow_logging"
  role = aws_iam_role.pre_auth_lambda.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
          ]
          Resource = "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "pre_auth_lambda_allow_ddb" {
  name = "allow_ddb"
  role = aws_iam_role.pre_auth_lambda.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Effect   = "Allow"
          Action   = "dynamodb:*"
          Resource = aws_dynamodb_table.login_attempts.arn
        }
      ]
    }
  )
}

resource "aws_iam_role_policies_exclusive" "pre_auth_lambda" {
  role_name = aws_iam_role.pre_auth_lambda.name
  policy_names = [
    aws_iam_role_policy.pre_auth_lambda_allow_logging.name,
    aws_iam_role_policy.pre_auth_lambda_allow_ddb.name
  ]
}
