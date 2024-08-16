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

resource "aws_network_interface" "nat_gateway_nic" {
  subnet_id = aws_subnet.public_subnets[var.nat_gw_ext_subnet].id
  security_groups = [aws_security_group.nat_gw_allow.id]
  source_dest_check = false

  tags = {
    Name = "${var.vpc_name_label}_nat_gw_nic_ext"
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

resource "aws_instance" "nat_gateway" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.micro" #This will qualify for the free tier
  key_name = var.ssh_keypair
  iam_instance_profile = var.instance_profile
  user_data = file("${path.module}/scripts/nat_gw_user_data.sh")
  
  
  network_interface {
    network_interface_id = aws_network_interface.nat_gateway_nic.id
    device_index = 0
    
  }

  tags = {
    Name = "${var.vpc_name_label}_nat_gw"
  }
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
        network_interface_id = aws_network_interface.nat_gateway_nic.id #Send all traffic to the NAT VM
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