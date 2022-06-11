# ----- Security Group
resource "aws_security_group" "lb" {
  vpc_id = var.vpc_id

  name = "${local.prefix}-loadbalancer"

  dynamic "ingress" {
    for_each = local.web_allow

    content {
      protocol = local.tcp_protocol
      from_port = ingress.value
      to_port = ingress.value
      cidr_blocks = local.all_ips
    }
  }

  egress {
    protocol = local.all_protocol
    from_port = 0
    to_port = 0
    cidr_blocks = local.all_ips
  }

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-loadbalancer"
    }
  )
}

# ----- Load Balancer
resource "aws_lb" "this" {
  name = "${local.prefix}-loadbalancer"
  subnets = var.public_subnet_ids
  load_balancer_type = "application"
  security_groups = [aws_security_group.lb.id]

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-loadbalancer"
    }
  )
}

resource "aws_lb_listener" "https_forward" {
  load_balancer_arn = aws_lb.this.arn
  port = local.web_allow["https"]
  protocol = "HTTPS"
  certificate_arn = aws_acm_certificate.this.arn
  ssl_policy = "ELBSecurityPolicy-2016-08"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

resource "aws_lb_listener" "http_forward" {
  load_balancer_arn = aws_lb.this.arn
  port = local.web_allow["http"]
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port = "443"
      protocol = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "this" {
  name = "${local.prefix}-terget-group"
  port = local.web_allow["http"]
  protocol = "HTTP"

  vpc_id = var.vpc_id
  target_type = "ip"

  health_check {
    enabled = true
    interval = 300
    path = "/"
    timeout = 60
    matcher = "200"
    healthy_threshold = 5
    unhealthy_threshold = 5
  }
}

