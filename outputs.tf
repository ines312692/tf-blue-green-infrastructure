# outputs.tf
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL of the application"
  value       = var.certificate_arn != "" ? "https://${module.alb.alb_dns_name}" : "http://${module.alb.alb_dns_name}"
}

output "blue_target_group_arn" {
  description = "ARN of blue target group"
  value       = module.alb.blue_target_group_arn
}

output "green_target_group_arn" {
  description = "ARN of green target group"
  value       = module.alb.green_target_group_arn
}

output "blue_cluster_name" {
  description = "Name of blue ECS cluster"
  value       = module.blue_environment.cluster_name
}

output "green_cluster_name" {
  description = "Name of green ECS cluster"
  value       = module.green_environment.cluster_name
}

output "blue_service_name" {
  description = "Name of blue ECS service"
  value       = module.blue_environment.service_name
}

output "green_service_name" {
  description = "Name of green ECS service"
  value       = module.green_environment.service_name
}

output "active_environment" {
  description = "Currently active environment"
  value       = var.active_environment
}

output "domain_url" {
  description = "Custom domain URL (if configured)"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "Not configured"
}

output "deployment_status" {
  description = "Current deployment status"
  value = {
    active_environment = var.active_environment
    blue_tasks         = var.active_environment == "blue" ? var.desired_count : var.standby_count
    green_tasks        = var.active_environment == "green" ? var.desired_count : var.standby_count
    blue_image         = var.blue_container_image
    green_image        = var.green_container_image
  }
}