provider "aws" {
  region = var.region
}

module "backend" {
  source = "../../modules/backend"

  app = var.app
  env = terraform.workspace
  domain = var.domain
  region = var.region

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  desired_count = 3
  host_port = 0
  container_port = 0
  container_spec_path = "test.tpl"
}
