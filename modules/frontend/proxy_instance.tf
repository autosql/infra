
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
  security_groups = [aws_security_group.proxy.id]

  key_name = "autosql-dev"

  tags = merge(
    local.tags, {
      Name = "${local.prefix}-reverse-proxy"
    }
  )

  user_data = <<-EOF
  #!/bin/bash -ex
  sudo -i
  apt update -y
  apt install -y nginx
  echo "server {listen 80; server_name _; location / {proxy_pass http://${aws_s3_bucket.frontend["landing"].website_endpoint};} location /erd {proxy_pass http://${aws_s3_bucket.frontend["erd"].website_endpoint};} }" > /etc/nginx/sites-enabled/default
  systemctl restart nginx
  EOF
}
