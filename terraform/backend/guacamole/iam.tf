resource "aws_iam_role" "ec2" {
  name = "platform.ec2.guacamole.role"
  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "sts:AssumeRole",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Effect" : "Allow"
        }
      ]
    }
  )
}

resource "aws_iam_role_policy" "ec2" {
  name = "ec2"
  role = aws_iam_role.ec2.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "ec2:CreateTags",
          "Resource" : "arn:aws:ec2:*:${var.common.account_id}:instance/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:Get*",
            "s3:List*"
          ],
          "Resource" : [
            "arn:aws:s3:::${var.common.terraform_bucket.bucket}",
            "arn:aws:s3:::${var.common.terraform_bucket.bucket}/*",
            "arn:aws:s3:::${var.common.disk_alert_linux_script.bucket}",
            "arn:aws:s3:::${var.common.disk_alert_linux_script.bucket}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "ssm:GetParameters",
            "ssm:GetParameter",
            "kms:Decrypt"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }
  )
}

resource "aws_iam_role_policies_exclusive" "ec2" {
  role_name = aws_iam_role.ec2.name
  policy_names = [
    aws_iam_role_policy.ec2.name,
  ]
}

resource "aws_iam_instance_profile" "ec2" {
  name = "platform.ec2.guacamole.profile"
  role = aws_iam_role.ec2.name
}
