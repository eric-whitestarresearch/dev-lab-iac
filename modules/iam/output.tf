output "ssm_profile_name" {
  value = aws_iam_instance_profile.ssm_profile.name
  description = "Name fo the profile created to use SSM"
}

output "lf_k8s_profile_name" {
  value = aws_iam_instance_profile.lf_k8s_profile.name
  description = "Name fo the profile created for k8s nodes"
}

