provider "aws" {
  region = var.region
}

module "database" {
  source = "../../modules/database"

  app = var.app
  env = terraform.workspace

  domain = var.domain
  region = var.region

  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  instance_type = "db.t2.micro"
  database_port = 3306

  MYSQL_USER = "admin"
  MYSQL_PASSWORD = var.MYSQL_PASSWORD
}
