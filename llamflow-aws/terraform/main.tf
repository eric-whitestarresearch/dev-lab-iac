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
  nat_gw_int_subnet = local.json_data.nat_gw_int_subnet
  nat_gw_ext_subnet = local.json_data.nat_gw_ext_subnet
  ssh_keypair = local.json_data.ec2_ssh_key_name
  instance_profile = module.iam.ssm_profile_name
}

module "vpc_endpoints" {
  source = "${path.module}/../../modules/vpc_endpoints"
  for_each = toset(local.json_data.vpc_endpoints.service_names)
  endpoint_name = "${local.json_data.vpc_name}_${each.value}_ep"
  service_name = "com.amazonaws.${data.aws_region.current.name}.${each.value}"
  vpc_id = module.vpc.vpc_info.vpc.id
  subnet_a_name = local.json_data.vpc_endpoints.az_a_subnet_name
  subnet_b_name = local.json_data.vpc_endpoints.az_b_subnet_name
  subnet_c_name = local.json_data.vpc_endpoints.az_c_subnet_name
}