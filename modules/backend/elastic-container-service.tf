# ----- vpc security group
# depend_on aws_security_group.lb
resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id
  name = "${local.prefix}-ecs"

  ingress {
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips
    from_port = var.host_port
    to_port = var.container_port

    security_groups = [aws_security_group.lb.id]
  }

  egress {
    protocol = local.all_protocol
    from_port = 0
    to_port = 0
    cidr_blocks = local.all_ips
  }
}
