locals {
  tags = {
    app = var.app
    env = terraform.workspace
    managed = "terraform"
  }
  prefix = "${var.app}-${terraform.workspace}"
}

provider "aws" {
  region = var.region
}

module "dns" {
  source = "../../global/host_zone"

  domain = var.domain
}

variable "app_records" {
  type = list(string)
  default = ["landing", "erd", "api", "db"]
}

resource "aws_route53_record" "index" {
  zone_id = module.dns.current_zone
  name = "${terraform.workspace}.${var.domain}"
  type = "A"

  records = ["${data.terraform_remote_state.frontend.outputs.domain_name}/landing/"]
}

resource "aws_route53_record" "erd" {
  zone_id = module.dns.current_zone
  name = "${terraform.workspace}.erd.${var.domain}"
  type = "A"

  records = ["${data.terraform_remote_state.frontend.outputs.domain_name}/erd/"]
}
