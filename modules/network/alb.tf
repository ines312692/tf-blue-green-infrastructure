
# Create an ALB Target Group with health checks configured
resource "aws_lb_target_group" "tg" {
  name     = "${var.prefix}-${var.environment}-tg"
  port     = var.load_balancer.lb_target_group.port
  protocol = var.load_balancer.lb_target_group.protocol
  vpc_id   = aws_vpc.this.id

  health_check {
    path                = var.load_balancer.lb_health_check.path
    interval            = var.load_balancer.lb_health_check.interval
    timeout             = var.load_balancer.lb_health_check.timeout
    healthy_threshold   = var.load_balancer.lb_health_check.healthy_threshold
    unhealthy_threshold = var.load_balancer.lb_health_check.unhealthy_threshold
    matcher             = var.load_balancer.lb_health_check.matcher
  }

  tags = {
    Name = "${var.prefix}-${var.environment}-tg"
  }
}

# Create the Application Load Balancer (ALB)
resource "aws_lb" "alb" {
  name                       = "${var.prefix}-${var.environment}-alb"
  load_balancer_type         = var.load_balancer.alb_settings.load_balancer_type
  security_groups            = [aws_security_group.alb.id]
  subnets                    = aws_subnet.public[*].id
  internal                   = var.load_balancer.alb_settings.internal
  enable_deletion_protection = var.load_balancer.alb_settings.enable_deletion_protection

  tags = {
    Name = "${var.prefix}-${var.environment}-alb"
  }
}

# Create a listener on the ALB for incoming HTTP/HTTPS traffic
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.load_balancer.listener.port.http
  protocol          = var.load_balancer.listener.protocol.http

  default_action {
    type             = var.load_balancer.listener.action_type
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.alb.arn
#   port              = var.load_balancer.listener.port.https
#   protocol          = var.load_balancer.listener.protocol.https
#   ssl_policy        = "ELBSecurityPolicy-2016-08"
#   certificate_arn   = aws_acm_certificate.cert.arn
#   default_action {
#     type             = var.load_balancer.listener.action_type
#     target_group_arn = aws_lb_target_group.tg.arn
#   }
# }

# # --------------------------
# # ACM Certificate
# # --------------------------
# resource "aws_acm_certificate" "cert" {
#   domain_name       = "yourdomain.com"
#   validation_method = "DNS"
#   tags = {
#     Name = "i360moms-com-cert"
#   }
# }

# # --------------------------
# # Route 53 Validation
# # --------------------------
# data "aws_route53_zone" "yourdomain" {
#   name         = "yourdomain.com."
#   private_zone = false
# }

# resource "aws_route53_record" "cert_validation" {
#   name    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_name
#   type    = aws_acm_certificate.cert.domain_validation_options[0].resource_record_type
#   zone_id = data.aws_route53_zone.fekri.zone_id
#   records = [aws_acm_certificate.cert.domain_validation_options[0].resource_record_value]
#   ttl     = 60
# }

# resource "aws_acm_certificate_validation" "cert" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
# }