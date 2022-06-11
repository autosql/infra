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
