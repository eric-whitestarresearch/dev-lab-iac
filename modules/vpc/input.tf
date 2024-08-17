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

variable "public_subnets" {
  type = map
  description = "A list of the public subnets to create in the vpc"
}

variable "private_subnets" {
  type = map
  description = "A list of the private subnets to create in the vpc"
}

variable "nat_gw_ext_subnet" {
  type = string
  description = "The subnet to place the NAT gateway external interface in"
}

variable "ssh_keypair" {
  type = string
  description = "The name of the SSH pair to assign to the NAT gateway VM"
}

variable "instance_profile" {
  type = string
  description = "THe name of the instance profile to attach the NAT VM to."
}