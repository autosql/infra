data "aws_route53_zone" "this" {
  name = var.domain
}

module "acm" {
  source = "../../modules/acm"

  app = var.app
  env = terraform.workspace
  domain = var.domain
  route53_zone_id = data.aws_route53_zone.this.zone_id
}
