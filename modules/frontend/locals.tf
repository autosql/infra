locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = var.env
    tier = "frontend"
  }
  prefix = "${var.app}-${var.env}"
  domain_name = "%{if var.env != "prod"}${var.env}.%{endif}${var.domain}"

  # ----- Security Group local variables

  web_allow = {
    http = 80
    https = 443
    ssh = 22
  }

  all_ips = ["0.0.0.0/0"]
  all_protocol = "-1"
  tcp_protocol = "tcp"
}
