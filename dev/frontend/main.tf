provider "aws" {
  region = var.region
}

module "frontend" {
  source = "../../modules/frontend"

  app = var.app
  env = terraform.workspace
  domain = var.domain

  bucket_names = ["landing", "erd"]
  bucket_acl = "public-read"
}
