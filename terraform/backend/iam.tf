resource "aws_iam_role" "portal_lambdas" {
  name = "platform.lambda.${var.common.app_slug}.${var.module_slug}.role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "lambda.amazonaws.com",
            "AWS" : "arn:aws:iam::${var.common.account_id}:root"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )
  tags = local.common_tags
}

resource "aws_iam_role_policy" "portal_lambdas_allow_logs" {
  name = "allow_logs"
  role = aws_iam_role.portal_lambdas.id
  policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:PutMetricFilter",
            "logs:PutRetentionPolicy"
          ],
          Resource : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "portal_lambdas_api_handler" {
  name = "api_handler"
  role = aws_iam_role.portal_lambdas.id
  policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "ses:SendEmail",
            "pricing:DescribeServices",
            "pricing:GetAttributeValues",
            "s3:*",
            "apigateway:*",
            "appstream:*",
            "dynamodb:*",
            "ec2:*",
            "pricing:GetProducts",
          ],
          Resource : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "portal_lambdas_reset_temp_password" {
  name = "reset_temp_password"
  role = aws_iam_role.portal_lambdas.id
  policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Effect : "Allow",
          Action : [
            "ec2:CreateNetworkInterface",
            "ec2:DescribeNetworkInterfaces",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeSecurityGroups",
            "ec2:DescribeSubnets",
            "ec2:DescribeVpcs",
            "cognito-idp:AdminGetUser",
            "cognito-idp:AdminDeleteUser",
            "cognito-idp:AdminLinkProviderForUser",
            "cognito-idp:ListUsers",
            "cognito-idp:AdminCreateUser",
            "ssm:GetParameters",
          ],
          Resource : "*"
        }
      ]
    }
  )
}

resource "aws_iam_role_policies_exclusive" "portal_lambdas" {
  role_name    = aws_iam_role.portal_lambdas.name
  policy_names = [
    aws_iam_role_policy.portal_lambdas_allow_logs.name,
    aws_iam_role_policy.portal_lambdas_api_handler.name,
    aws_iam_role_policy.portal_lambdas_reset_temp_password.name,
    ]
}
