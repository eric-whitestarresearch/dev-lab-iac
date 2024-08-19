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

output "instance_info" {
  value = {
    dev_workstation = module.dev_workstation.instance_info,
    kubernetes_nodes = {for node in module.kubernetes_nodes: node.instance_info.name => node.instance_info}

  }
}
