terraform {
  required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
  }
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
            "Resource": "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:function:lf_microk8s_new_node"
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

  managed_policy_arns = [data.aws_iam_policy.ssm_policy.arn, data.aws_iam_policy.ebscsi_policy.arn,aws_iam_policy.lf_k8s_add_node.arn]


  tags = {
    Name = "lf_k8s_role"
  }
}

resource "aws_iam_instance_profile" "lf_k8s_profile" {
  name = "lf_k8s_profile"
  role = aws_iam_role.lf_k8s_role.name
}

resource "aws_iam_policy" "lf_microk8s_new_node_lambda" {
  name = "lf_microk8s_new_node_lambda"
  path = "/"
  description = "Allows mthe lamda that creates adds new k8s nodes to run"

  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "logs:CreateLogGroup",
          "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource": [
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:/aws/lambda/lf_microk8s_new_node:*"
          ]
        },
        {
          "Effect": "Allow",
          "Action": [
            "ec2:DescribeInstances"
          ],
          "Resource": "*"
        }
      ]
    }
  )
}

resource "aws_iam_role" "lf_microk8s_new_node_lambda_role" {
  name = "lf_microk8s_new_node_lambda_role"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
        "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [data.aws_iam_policy.ssm_policy.arn, aws_iam_policy.lf_microk8s_new_node_lambda.arn]


  tags = {
    Name = "lf_microk8s_new_node_lambda_role"
  }
}