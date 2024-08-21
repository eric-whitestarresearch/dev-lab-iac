output "iam_info" {
  value = {
    ssm_profile = {
      name = aws_iam_instance_profile.ssm_profile.name,
      arn = aws_iam_instance_profile.ssm_profile.arn,
      id = aws_iam_instance_profile.ssm_profile.id
    },
    lf_k8s_profile = {
      name = aws_iam_instance_profile.lf_k8s_profile.name,
      arn = aws_iam_instance_profile.lf_k8s_profile.arn,
      id = aws_iam_instance_profile.lf_k8s_profile.id
    },
    lf_microk8s_new_node_role = {
      name = aws_iam_role.lf_microk8s_new_node_lambda_role.name,
      arn = aws_iam_role.lf_microk8s_new_node_lambda_role.arn,
      id = aws_iam_role.lf_microk8s_new_node_lambda_role.id
    }
  }
}


