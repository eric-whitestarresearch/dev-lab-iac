output "zone_info" {
  value = {
    zone_name = var.zone_name
    arn = aws_route53_zone.hosted_zone.arn
    id = aws_route53_zone.hosted_zone.zone_id
    name_servers = aws_route53_zone.hosted_zone.name_servers
    primary_name_server = aws_route53_zone.hosted_zone.primary_name_server
  }
}