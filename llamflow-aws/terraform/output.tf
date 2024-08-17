output "vpc_info" {
  value = module.vpc.vpc_info
  description = "Information about the created VPC"
}

output "vpc_endpoints" {
  value ={
    for endpoint in module.vpc_endpoints: endpoint.vpc_endpoint_info.endpoint_name => endpoint.vpc_endpoint_info
  }
  description = "Information about the created VPC endpoints"
}

output "internal_dns_zone" {
  value = module.internal_private_zone.zone_info
}
