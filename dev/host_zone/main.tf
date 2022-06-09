provider "aws" {
  region = var.region
}

module "dns" {
  source = "../../global/host_zone"

  domain = var.domain
}

module "host_zone" {
  source = "../../modules/host_zone"

  app = var.app

  region = var.region
  domain = var.domain
  route53_zone_id = module.dns.current_zone

  env = terraform.workspace

  cloudfront_info = {
    name = data.terraform_remote_state.frontend.outputs.domain_name
    zone_id = data.terraform_remote_state.frontend.outputs.hosted_zone_id
  }

  app_dns_info = {
    landing = {
      name = data.terraform_remote_state.frontend.outputs.domain_name
      path = "landing"
      tier = "frontend"
      type = "A"
    },
    erd = {
      name = data.terraform_remote_state.frontend.outputs.domain_name
      path = "erd"
      tier = "frontend"
      type = "A"
    }
  }

  remove_record = "landing"

}
