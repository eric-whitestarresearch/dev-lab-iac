data "aws_vpc" "target_vpc" {
  id = var.vpc_id
}

data "aws_subnets" "az_a_subnet" {
  tags = {
    Name = var.subnet_a_name
  }
}

data "aws_subnets" "az_b_subnet" {
  tags = {
    Name = var.subnet_b_name
  }
}

data "aws_subnets" "az_c_subnet" {
  tags = {
    Name = var.subnet_c_name
  }
}