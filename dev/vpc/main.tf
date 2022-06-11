provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  app = var.app
  env = terraform.workspace
}
