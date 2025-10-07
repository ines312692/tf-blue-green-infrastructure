# main.tf
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    # Backend config is provided via backend.tf in environment folders
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "BlueGreenDeployment"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  }
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  environment         = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnets     = var.public_subnets
  private_subnets    = var.private_subnets
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"

  environment          = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnet_ids
  alb_security_group  = module.security_groups.alb_security_group_id
  certificate_arn     = var.certificate_arn
  container_port      = var.container_port
  health_check_path   = var.health_check_path
}

# Blue Environment (ECS Service)
module "blue_environment" {
  source = "./modules/ecs-service"

  environment           = "${var.environment}-blue"
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnet_ids
  ecs_security_group   = module.security_groups.ecs_security_group_id
  target_group_arn     = module.alb.blue_target_group_arn
  container_image      = var.blue_container_image
  container_port       = var.container_port
  desired_count        = var.active_environment == "blue" ? var.desired_count : var.standby_count
  cpu                  = var.task_cpu
  memory               = var.task_memory
  health_check_path    = var.health_check_path
  app_name             = var.app_name
}

# Green Environment (ECS Service)
module "green_environment" {
  source = "./modules/ecs-service"

  environment           = "${var.environment}-green"
  vpc_id               = module.vpc.vpc_id
  private_subnets      = module.vpc.private_subnet_ids
  ecs_security_group   = module.security_groups.ecs_security_group_id
  target_group_arn     = module.alb.green_target_group_arn
  container_image      = var.green_container_image
  container_port       = var.container_port
  desired_count        = var.active_environment == "green" ? var.desired_count : var.standby_count
  cpu                  = var.task_cpu
  memory               = var.task_memory
  health_check_path    = var.health_check_path
  app_name             = var.app_name
}

# Route53 DNS (Optional)
module "route53" {
  source = "./modules/route53"
  count  = var.domain_name != "" ? 1 : 0

  domain_name = var.domain_name
  alb_dns     = module.alb.alb_dns_name
  alb_zone_id = module.alb.alb_zone_id
  environment = var.environment
}

# CloudWatch Monitoring
module "monitoring" {
  source = "./modules/monitoring"

  environment                = var.environment
  alb_arn_suffix            = module.alb.alb_arn_suffix
  blue_target_group_suffix  = module.alb.blue_target_group_arn_suffix
  green_target_group_suffix = module.alb.green_target_group_arn_suffix
  blue_cluster_name         = module.blue_environment.cluster_name
  green_cluster_name        = module.green_environment.cluster_name
  blue_service_name         = module.blue_environment.service_name
  green_service_name        = module.green_environment.service_name
  alarm_email               = var.alarm_email
}