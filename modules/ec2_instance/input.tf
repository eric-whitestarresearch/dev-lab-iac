variable "instance_type" {
  type = string
  description = "The type of instance to create"
}

variable "vpc_id" {
  type = string
  description = "The ID of the VPC to crate the instance in"
}

variable "subnet_id" {
  type = string
  description = "The id of the subnet to place the instance in"
}

variable "security_group_id" {
  type = string
  description = "The id of the security group to attach to the instance"
}

variable "user_data" {
  type = string
  nullable = true
  default = null
  description = "The user data to add to the instance"
}

variable "instance_name" {
  type = string
  description = "The name of the instance"
}

variable "ssh_keypair" {
  type = string
  description = "The name of the SSH pair to assign to the NAT gateway VM"
}

variable "instance_profile" {
  type = string
  description = "THe name of the instance profile to attach the NAT VM to."
}

variable "route53_zone_id" {
  type = string
  description = "The id of the route53 zone to create the DNS records in for the instance"
}

variable "create_dns_record" {
 type = bool
 default = true
 description = "Should a DNS record be created for the instance. Requries route53_zone_id"

}

variable "additional_tags" {
  type = map 
  default = {}
  description = "Any additoinal tags to add"
}

variable "root_device_size" {
  type = string
  default = "8"
  description = "The size of the EBS volume for the root device"
}

variable "root_device_type" {
  type = string
  default = "gp2"
  description = "The volume type of the root device"
}

variable "hibernation_enabled" {
  type = bool
  default = false
  description = "Should hibernation be enabled for the instances"
}

variable "source_dest_check" {
  type = bool
  default = true
  description = "Enable/Disable the check that the packet destination IP is the same as the IP as the nic. Needed for for NAT instances"
}

variable "amazon_linux_os" {
  type = bool
  default = false
  description = "If true use Amazon linux AMI, If false use Ubuntu"
}