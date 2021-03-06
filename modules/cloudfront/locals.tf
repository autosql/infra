locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = var.env
    tier = "cloudfront"
  }
  prefix = "${var.app}-${var.env}"
  domain_name = "%{if var.env != "prod"}${var.env}.%{endif}${var.domain}"
}
