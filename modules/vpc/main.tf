terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


resource "aws_vpc" "vpc" {
  cidr_block =  var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames  = true
  tags = {
    Name = var.vpc_name_label
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.vpc.id
  for_each = var.public_subnets
  
  cidr_block = each.value.cidr
  availability_zone = each.value.zone
  map_public_ip_on_launch = true
  tags = {
    Name = each.value.name
  }
}

resource "aws_subnet" "private_subnets" {
  vpc_id = aws_vpc.vpc.id
  for_each = var.private_subnets
  
  cidr_block = each.value.cidr
  availability_zone = each.value.zone
  map_public_ip_on_launch = false
  tags = {
    Name = each.value.name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.vpc_name_label}_igw"
  }
}

resource "aws_security_group" "nat_gw_allow" {
  name = "nat_gw_allow"
  description = "Allow traffic to an from the NAT gateway VM"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "nat_gw_allow"
  } 

  #Allow all out bound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [var.vpc_cidr]
  }
}

module "nat_instance" {
  source = "${path.module}/../ec2_instance"
  instance_type = "t4g.micro"
  vpc_id = aws_vpc.vpc.id
  subnet_id = aws_subnet.public_subnets[var.nat_gw_ext_subnet].id
  security_group_id = aws_security_group.nat_gw_allow.id
  user_data = file("${path.module}/scripts/nat_gw_user_data.sh")
  instance_name = "${var.vpc_name_label}_nat_gw"
  ssh_keypair = var.ssh_keypair
  instance_profile = var.instance_profile
  route53_zone_id = null
  create_dns_record = false
  root_device_size = "8"
  root_device_type = "gp3"
  hibernation_enabled = var.hibernation_enabled
  source_dest_check = false
  amazon_linux_os = true
}
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id= aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name_label}_pub_rt"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    network_interface_id = module.nat_instance.instance_info.nic_id #Send all traffic to the NAT VM
  }

  tags = {
    Name = "${var.vpc_name_label}_private_rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  for_each = aws_subnet.public_subnets

  route_table_id = aws_route_table.public_route_table.id
  subnet_id = each.value.id

}

resource "aws_route_table_association" "private_rt_assoc" {
  for_each = aws_subnet.private_subnets

  route_table_id = aws_route_table.private_route_table.id
  subnet_id = each.value.id

}