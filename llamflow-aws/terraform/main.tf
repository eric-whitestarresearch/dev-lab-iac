terraform {
  required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
    }
  }
  backend "s3" {
    key = "lf-dev-aws-state"
  }
}

#Get the config json
locals {
  json_data = jsondecode(file(var.env_config_file))
}

# Configure the AWS Provider
provider "aws" {
  region = local.json_data.region
  allowed_account_ids = local.json_data.allowed_account_ids
}

module "iam" {
  source = "${path.module}/../../modules/iam"
}

module "vpc" {
  source = "${path.module}/../../modules/vpc"
  vpc_cidr =  local.json_data.vpc_cidr
  vpc_name_label = local.json_data.vpc_name
  public_subnets = local.json_data.public_subnets
  private_subnets = local.json_data.private_subnets
  nat_gw_ext_subnet = local.json_data.nat_gw_subnet
  ssh_keypair = local.json_data.ec2_ssh_key_name
  instance_profile = module.iam.iam_info.ssm_profile.name
}

module "vpc_endpoints" {
  source = "${path.module}/../../modules/vpc_endpoints"
  #Only create the endpoints if enabled in the config file
  for_each = local.json_data.vpc_endpoints.endpoints_enabled ? toset(local.json_data.vpc_endpoints.service_names) : toset([])
  endpoint_name = "${local.json_data.vpc_name}_${each.value}_ep"
  service_name = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_id = module.vpc.vpc_info.vpc.id
  subnet_a_name = local.json_data.vpc_endpoints.az_a_subnet_name
  subnet_b_name = local.json_data.vpc_endpoints.az_b_subnet_name
  subnet_c_name = local.json_data.vpc_endpoints.az_c_subnet_name
}

module "lamba_functions" {
  source = "${path.module}/../../modules/lambda"
  microk8s_add_node_role_arn = module.iam.iam_info.lf_microk8s_new_node_role.arn
}

module "internal_private_zone" {
  source = "${path.module}/../../modules/dns_zone"
  private_zone = true
  target_vpc_id = module.vpc.vpc_info.vpc.id
  zone_name = local.json_data.priave_dns_zone
}

resource "aws_security_group" "dev_sg" {
  name =  "lf_dev_instance_sg"
  description = "SG for development ec2 instances"
  vpc_id = module.vpc.vpc_info.vpc.id

  tags = {
    Name = "lf_dev_instance_sg"
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
    cidr_blocks = [module.vpc.vpc_info.vpc.cidr_block]
  }
}

module "dev_workstation" {
  source = "${path.module}/../../modules/ec2_instance"
  instance_type = "t3.micro"
  vpc_id = module.vpc.vpc_info.vpc.id
  subnet_id = module.vpc.vpc_info.private_subnets[local.json_data.dev_workstation.subnet_name].id
  security_group_id = aws_security_group.dev_sg.id
  user_data = null
  instance_name = "lf_dev_workstation"
  ssh_keypair = local.json_data.ec2_ssh_key_name
  instance_profile = module.iam.iam_info.ssm_profile.name
  route53_zone_id = module.internal_private_zone.zone_info.id
  root_device_size = local.json_data.dev_workstation.disk_size
  root_device_type = local.json_data.dev_workstation.disk_type
}

module "kubernetes_nodes" {
  source = "${path.module}/../../modules/ec2_instance"
  for_each = local.json_data.kubernetes_nodes
  instance_type = local.json_data.kubernetes_instance_type
  
  vpc_id = module.vpc.vpc_info.vpc.id
  subnet_id = module.vpc.vpc_info.private_subnets[each.value.subnet_name].id
  security_group_id = aws_security_group.dev_sg.id
  user_data = file("${path.module}/scripts/lf_dev_k8s_up.sh")
  instance_name = each.value.name
  ssh_keypair = local.json_data.ec2_ssh_key_name
  instance_profile = module.iam.iam_info.lf_k8s_profile.name
  route53_zone_id = module.internal_private_zone.zone_info.id
  additional_tags = each.value.tags
  root_device_size = local.json_data.kubernetes_disk_size
  root_device_type = local.json_data.kubernetes_disk_type

}