terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_iam_policy" "ssm_policy" {
    name = "AmazonSSMFullAccess"
}

resource "aws_iam_role" "ssm_mgmt_ec2_role" {
    name = "ssm_mgmt_ec2_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Sid    = ""
            Principal = {
            Service = "ec2.amazonaws.com"
            }
        },
        ]
    })

    managed_policy_arns = [data.aws_iam_policy.ssm_policy.arn]


    tags = {
        Name = "ssm_mgmt_ec2"
    }
}

resource "aws_iam_instance_profile" "ssm_profile" {
    name = "ssm_profile"
    role = aws_iam_role.ssm_mgmt_ec2_role.name
}
