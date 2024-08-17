variable "zone_name" {
  type = string
  description = "The DNS name of the zone to create"
}

variable "private_zone" {
  type = bool
  default = false
  description = "Is this a public or private zone"
}

variable "target_vpc_id" {
  type = string
  default = null
  nullable = true
  description = "If this is a private zone then we need the VPC to associate with"
}