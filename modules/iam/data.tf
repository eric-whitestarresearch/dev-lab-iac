data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy" "ssm_policy" {
  name = "AmazonSSMFullAccess"
}

data "aws_iam_policy" "ebscsi_policy" {
  name = "AmazonEBSCSIDriverPolicy"
}