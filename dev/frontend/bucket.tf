locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = terraform.workspace
  }
  prefix = "${var.app}-${terraform.workspace}"
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket
  acl = "private"

  versioning {
    enabled = true
  }

  tags = merge(
    local.tags, 
    {
      Name = "${local.prefix}-frontend-bucket"
    }
  )
}

