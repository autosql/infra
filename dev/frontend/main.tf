provider "aws" {
  region = var.region
}

module "frontend" {
  source = "../../modules/frontend"

  app = var.app
  env = terraform.workspace

  frontend_bucket = "autosql-frontend-bucket"
  bucket_acl = "public-read"
}
