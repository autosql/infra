provider "aws" {
  region = "us-east-1"
}

module "cloudfront" {
  source = "../../modules/cloudfront"

  app = var.app
  env = terraform.workspace
  domain = var.domain

  default_bucket = "landing"
  bucket_domain_names = data.terraform_remote_state.frontend.outputs.website_endpoints
}
