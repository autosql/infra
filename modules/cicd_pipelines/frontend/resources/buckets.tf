locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = terraform.workspace
  }
  prefix = "${var.app}-${terraform.workspace}"
}

resource "aws_s3_bucket" "pipeline" {
  bucket = "${var.pipeline_bucket}-${terraform.workspace}"

  acl = var.bucket_acl

  tags = merge(
    local.tags, {
      Name = "${prefix}-${var.pipeline_bucket}"
    }
  )
}

resource "aws_s3_bucket" "build" {
  bucket = "${var.build_bucket}-${terraform.workspace}"
  
  acl = var.bucket_ecl

  tags = merge(
    local.tags, {
      Name = "${prefix}-${var.build_bucket}"
    }
  )
}
