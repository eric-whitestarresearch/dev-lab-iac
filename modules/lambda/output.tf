output "lambda_info" {
  value = {
    lf_microk8s_new_node = {
      arn = aws_lambda_function.microk8s_add_node.arn,
      id = aws_lambda_function.microk8s_add_node.id,
      sha256_checksum = aws_lambda_function.microk8s_add_node.code_sha256,
      name = aws_lambda_function.microk8s_add_node.function_name
    }
  }
}