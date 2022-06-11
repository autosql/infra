provider "aws" {
  region = var.region
}

module "backend" {
  source = "../../modules/backend"

  app = var.app
  env = terraform.workspace
  domain = var.domain

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  host_port = 0
  container_port = 0
}
