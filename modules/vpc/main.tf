terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_vpc" "vpc" {
  cidr_block       =  var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = var.vpc_name_label
  }
}