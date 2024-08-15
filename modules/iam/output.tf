output "ssm_profile_name" {
    value = aws_iam_instance_profile.ssm_profile.name
    description = "Name fo the profile created to use SSM"
}