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
      Sid  = ""
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

resource "aws_iam_policy" "lf_k8s_add_node" {
  name = "lf_k8s_add_node"
  path = "/"
  description = "Allows microk8s nodes to run lamba to add node to cluster"

  policy = jsonencode(
    {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "lambda:InvokeFunction",
            "Resource": "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:microk8s_new_node"
        }
    ]
  }
  )
}

resource "aws_iam_role" "lf_k8s_role" {
  name = "lf_k8s_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
    {
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid  = ""
      Principal = {
      Service = "ec2.amazonaws.com"
      }
    },
    ]
  })

  managed_policy_arns = [data.aws_iam_policy.ssm_policy.arn, aws_iam_policy.lf_k8s_add_node.arn]


  tags = {
    Name = "lf_k8s_role"
  }
}

resource "aws_iam_instance_profile" "lf_k8s_profile" {
  name = "lf_k8s_profile"
  role = aws_iam_role.lf_k8s_role.name
}