terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

#Get the config json
locals {
    json_data = jsondecode(file("${path.module}/dev.json"))
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-2" #Virgina is for lovers, Ohio is for stability. 
  allowed_account_ids = local.json_data.allowed_account_ids
}

module "vpc" {
    source = "${path.module}/../../modules/vpc"
    vpc_cidr =  local.json_data.vpc_cidr
    vpc_name_label = local.json_data.vpc_name
}