terraform {
  backend "s3" {
    bucket = "autosql-infra-terraform-state" 
    key = "vpc/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "autosql-infra-terraform-locks"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source = "../../modules/vpc"

  app = var.app
  env = terraform.workspace
}
