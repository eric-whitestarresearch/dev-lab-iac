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
  region = "us-east-2" #Virgina is for lovers, Ohio is for stability. 
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