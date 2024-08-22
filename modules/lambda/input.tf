variable "microk8s_add_node_role_arn" {
  type = string
  description = "The arn of the role for the microk8s_add_node lambda function "
}

variable "lf_goodnight_role_arn" {
  type = string
  description = "The arn of the role for the lf_goodnight lambda function "
}