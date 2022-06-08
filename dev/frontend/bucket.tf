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

data "aws_iam_policy_document" "frontend_bucket_policy" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
    resources = [
      "arn:aws:s3:::${var.frontend_bucket}/*"
    ]
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket
  acl = var.bucket_acl

  policy = data.aws_iam_policy_document.frontend_bucket_policy.json

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

resource "aws_s3_bucket_website_configuration" "landing" {
  bucket = aws_s3_bucket.frontend.bucket

  index_document {
    suffix = "index.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "landing/"
    }

    redirect {
      replace_key_prefix_with = "landing/"
    }
  }
}
