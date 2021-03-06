terraform {
  backend "s3" {
    bucket = "autosql-infra-terraform-state" 
    key = "backend/terraform.tfstate" 
    region = "ap-northeast-2"

    dynamodb_table = "autosql-infra-terraform-locks"
    encrypt = true
  }
}

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

  desired_count = 1
  min_capacity = 1
  max_capacity = 3
  scale_policy = {
    ECSServiceAverageCPUUtilization = 60
    ECSServiceAverageMemoryUtilization = 80
  }

  host_port = 80
  container_port = 3000
  container_spec_path = "backend.config.json.tpl"

  MYSQL_USERNAME = "admin"
  MYSQL_DATABASE = "autosql"

  taskdef_path = "taskdef.json"
  appspec_path = "appspec.yaml"
}

