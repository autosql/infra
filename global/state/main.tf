terraform {
  backend "s3" {
    bucket = "autosql-infra-terraform-state" 
    key = "global/state/terraform.tfstate"
    region = "ap-northeast-2"

    dynamodb_table = "autosql-infra-terraform-locks" 
    encrypt = true
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

locals {
  tags = {
    app = "autosql"
    managed = "terraform"
  }
}

#####################################################
# ----- S3 Bucket
#####################################################
resource "aws_s3_bucket" "terraform_state" {
  bucket = "autosql-infra-terraform-state"

  lifecycle {
    prevent_destroy = true
  }

  tags = local.tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

#####################################################
# ----- DynamoDB Table
#####################################################
resource "aws_dynamodb_table" "terraform_locks" {
  name = "autosql-infra-terraform-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.tags
}
