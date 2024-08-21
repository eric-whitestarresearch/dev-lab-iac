terraform {
  required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
  }
}

resource "aws_lambda_function" "microk8s_add_node" {
  filename = data.archive_file.microk8s_add_node_python.output_path
  function_name = "lf_microk8s_new_node"
  role = var.microk8s_add_node_role_arn

  source_code_hash = data.archive_file.microk8s_add_node_python.output_base64sha256
  runtime = "python3.12"
  handler = "microk8s_add_node.lambda_handler"
  architectures = ["arm64"]
  timeout = 120
}