# modules/route53/variables.tf.tf
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "domain_name" {
  description = "Domain name"
  type        = string
}

variable "alb_dns" {
  description = "DNS name of ALB"
  type        = string
}

variable "alb_zone_id" {
  description = "Zone ID of ALB"
  type        = string
}