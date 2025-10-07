# modules/route53/outputs.tf
output "zone_id" {
  description = "Route53 hosted zone ID"
  value       = data.aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "Name servers for the hosted zone"
  value       = data.aws_route53_zone.main.name_servers
}

output "domain_url" {
  description = "Domain URL"
  value       = "https://${var.domain_name}"
}

output "health_check_id" {
  description = "Route53 health check ID"
  value       = aws_route53_health_check.main.id
}