terraform {
  backend "s3" {
    bucket = "autosql-infra-terraform-state" 
    key = "database/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "autosql-infra-terraform-locks"
    encrypt = true
  }
}

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
}
