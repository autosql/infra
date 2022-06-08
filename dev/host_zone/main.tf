locals {
  tags = {
    app = var.app
    env = terraform.workspace
    managed = "terraform"
  }
  prefix = "${var.app}-${var.env}"
}

provider "aws" {
  region = var.region
}

module "dns" {
  source = "../../global/host_zone"

  domain = var.domain
}

resource "aws_route53_record" "index" {
  zone_id = module.dns.current_zone
}
