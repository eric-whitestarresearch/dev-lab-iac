variable "endpoint_name" {
  type = string
  description = "The name of the endpoint to provision"
}

variable "service_name" {
  type = string
  description = "The service to provision"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC to provision the endpoints into"
}

variable "subnet_a_name" {
  type = string
  description = "The Name of the subnet for AZ a to provision into"
}

variable "subnet_b_name" {
  type = string
  description = "The Name of the subnet for AZ b to provision into"
}

variable "subnet_c_name" {
  type = string
  description = "The Name of the subnet for AZ c to provision into"
}

