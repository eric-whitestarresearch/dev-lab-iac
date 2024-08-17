output "vpc_endpoint_info" {
  value = {
    endpoint_name = var.endpoint_name
    arn = aws_vpc_endpoint.endpoint.arn
    id = aws_vpc_endpoint.endpoint.id
    service_name = aws_vpc_endpoint.endpoint.service_name
    security_group_id = aws_security_group.endpoint_sq.id
    security_group_arn = aws_security_group.endpoint_sq.arn
    security_group_name = aws_security_group.endpoint_sq.name
  }
  description = "The information about the newly created endpoint"
}


output "vpc_endpoint_info2" {
  value = aws_security_group.endpoint_sq.name
  description = "The information about the newly created endpoint"
}
