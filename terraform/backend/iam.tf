resource "aws_iam_role" "hello_world" {
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
  tags = local.common_tags
}

resource "aws_iam_role" "webportal_lambda" {
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
  tags = local.common_tags
}