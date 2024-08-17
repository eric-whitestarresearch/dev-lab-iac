terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_route53_zone" "hosted_zone" {
  name = var.zone_name
  
  dynamic "vpc" {
    for_each = var.private_zone ? ["private_zone"] : []
    content {
       vpc_id = var.target_vpc_id
    }
  }
}