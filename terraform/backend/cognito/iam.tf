resource "aws_iam_role" "this" {
  name = "${var.user_pool_name}_cognito_send_sms"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "",
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "cognito-idp.amazonaws.com"
          },
          "Action" : "sts:AssumeRole",
          "Condition" : {
            "StringEquals" : {
              "sts:ExternalId" : local.external_id,
              "aws:SourceAccount" : var.common.account_id
            },
            "ArnLike" : {
              "aws:SourceArn" : "arn:aws:cognito-idp:${var.common.region}:${var.common.account_id}:userpool/*"
            }
          }
        }
      ]
    }
  )
  tags = local.common_tags
}

resource "aws_iam_role_policy" "this" {
  name = "test_policy"
  role = aws_iam_role.this.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "sns:Publish",
          "Resource" : "*",
        }
      ]
    }
  )
}

resource "aws_iam_role_policies_exclusive" "this" {
  role_name    = aws_iam_role.this.name
  policy_names = [aws_iam_role_policy.this.name]
}
