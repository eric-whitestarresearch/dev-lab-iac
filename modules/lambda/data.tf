data "archive_file" "microk8s_add_node_python" {
  type = "zip"
  source_file = "${path.module}/scripts/microk8s_add_node.py"
  output_path = "${path.module}/zip/microk8s_add_node.zip"
}

data "archive_file" "goodnight_python" {
  type = "zip"
  source_file = "${path.module}/scripts/goodnight.py"
  output_path = "${path.module}/zip/goodnight.zip"
}