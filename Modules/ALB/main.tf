
#ALB
resource "aws_lb" "Production" {

  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.security_group_id
  ]

  subnets = var.subnet_ids

  enable_deletion_protection = false

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-alb"
    }
  )
}

#TargetGroup
resource "aws_lb_target_group" "Production" {

  name     = "${var.project_name}-${var.environment}-tg"
  port     = var.target_group_port
  protocol = var.target_group_protocol

  vpc_id = var.vpc_id

  target_type = "instance"

  health_check {

    enabled = true

    path = "/"

    port = "traffic-port"

    protocol = "HTTP"

    healthy_threshold   = 3
    unhealthy_threshold = 3

    timeout  = 5
    interval = 30

    matcher = "200"
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project_name}-${var.environment}-tg"
    }
  )
}

#Listener Rule
# ── HTTPS Listener (your existing one) ──────────────────────────────
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.Production.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Production.arn
  }
}

# ── HTTP → HTTPS Redirect Listener (new) ────────────────────────────
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.Production.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"   # permanent redirect
    }
  }
}