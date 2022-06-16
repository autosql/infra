terraform {
  backend "s3" {
    bucket = "autosql-infra-terraform-state" 
    key = "frontend/terraform.tfstate" 
    region = "ap-northeast-2"

    dynamodb_table = "autosql-infra-terraform-locks"
    encrypt = true
  }
}

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
