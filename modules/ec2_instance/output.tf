output "instance_info" {
  value = {
      "id" : aws_instance.instance.id
      "arn" : aws_instance.instance.arn,
      "name" : aws_instance.instance.tags.Name
      "nic_id" : aws_network_interface.instance_nic.id,
      "nic_arn" : aws_network_interface.instance_nic.arn
      "fqdn" : var.create_dns_record ? aws_route53_record.record["create_record"].fqdn : "none"
  }
}
