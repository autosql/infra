module "vpc" {
  source = "../../modules/vpc"

  app = var.app
  env = terraform.workspace
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

