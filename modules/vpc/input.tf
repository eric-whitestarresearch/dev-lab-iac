variable "vpc_cidr" {
    type = string
    description = "The CIDR to use for the VPC"
    nullable = false
}

variable "vpc_name_label" {
  type = string
  description = "What the name label on the VPC should be"
  nullable = false
}