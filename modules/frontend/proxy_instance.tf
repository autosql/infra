##############################################################
# ----- Security Group
##############################################################
resource "aws_security_group" "proxy" {
  vpc_id = var.vpc_id
  name = "${local.prefix}-reverse-proxy"

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
      Name = "${local.prefix}-reverse-proxy" 
    }
  )
}

##############################################################
# ----- Instance
##############################################################
resource "aws_eip" "proxy" {
  instance = aws_instance.proxy.id
  vpc = true

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-reverse-proxy-instance"
    }
  )
}

resource "aws_instance" "proxy" {
  ami = "ami-058165de3b7202099"
  instance_type = "t2.micro"

  subnet_id = var.public_subnet_ids[0]

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-reverse-proxy"
    }
  )
}
