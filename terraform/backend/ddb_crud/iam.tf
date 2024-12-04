resource "aws_iam_role" "ddb_crud_lambda" {
  name = "platform.lambda.${var.common.app_slug}.ddb_crud.role"
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

resource "aws_iam_role_policy" "ddb_crud_lambda_allow_logs" {
  name = "allow_logs"
  role = aws_iam_role.ddb_crud_lambda.id
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

resource "aws_iam_role_policy" "ddb_crud_lambda_api_handler" {
  name = "api_handler"
  role = aws_iam_role.ddb_crud_lambda.id
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

resource "aws_iam_role_policies_exclusive" "ddb_crud_lambda" {
  role_name = aws_iam_role.ddb_crud_lambda.name
  policy_names = [
    aws_iam_role_policy.ddb_crud_lambda_allow_logs.name,
    aws_iam_role_policy.ddb_crud_lambda_api_handler.name,
  ]
}
