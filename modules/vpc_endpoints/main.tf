terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_security_group" "endpoint_sq" {
  name = "${var.endpoint_name}_sg"
  description = "Allow traffic to a VPC endpoint"
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.endpoint_name}_sg"
  } 

  #Allow all out bound traffic
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow from the VPC
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = [data.aws_vpc.target_vpc.cidr_block]
  }
}

resource "aws_vpc_endpoint" "endpoint" {
  vpc_id = var.vpc_id
  service_name = var.service_name
  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.endpoint_sq.id]
  subnet_ids = [data.aws_subnets.az_a_subnet.ids[0],data.aws_subnets.az_b_subnet.ids[0],data.aws_subnets.az_c_subnet.ids[0]]
  private_dns_enabled = true

  tags = {
    Name = var.endpoint_name
  }
}