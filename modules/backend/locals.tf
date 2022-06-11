locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = var.env
  }
  prefix = "${var.app}-${var.env}"
  domain_name = "api.%{if var.env != "prod"}${var.env}.%{endif}${var.domain}"

  # ----- Security Group local variables

  web_allow = {
    http = 80
    https = 443
  }

  all_ips = ["0.0.0.0/0"]
  all_protocol = "-1"
  tcp_protocol = "tcp"
}
