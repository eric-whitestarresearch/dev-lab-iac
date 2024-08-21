terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_network_interface" "instance_nic" {
  subnet_id = var.subnet_id
  security_groups = [var.security_group_id]
  source_dest_check = true

  tags = {
    Name = "${var.instance_name}_nic"
  }
}

resource "aws_instance" "instance" {
  ami = data.aws_ami.ubuntu_22_x64.id
  instance_type = var.instance_type
  key_name = var.ssh_keypair
  iam_instance_profile = var.instance_profile
  user_data = var.user_data

  root_block_device {
    volume_size = var.root_device_size
    volume_type = var.root_device_type
  }
 
  network_interface {
    network_interface_id = aws_network_interface.instance_nic.id
    device_index = 0
  }

  tags = merge({
    Name = "${var.instance_name}"
  }, var.additional_tags)
}

resource "aws_route53_record" "record" {
  zone_id = var.route53_zone_id
  name = var.instance_name
  type = "A"
  ttl = 300
  records = [aws_network_interface.instance_nic.private_ip]
}