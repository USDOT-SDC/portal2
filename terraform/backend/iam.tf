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
  inline_policy {
    name = "allow_logs"
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
  inline_policy {
    name = "api_handler"
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
  tags = local.common_tags
}
