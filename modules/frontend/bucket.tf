locals {
  tags = {
    app = var.app
    managed = "terraform"
    env = var.env
  }
  prefix = "${var.app}-${var.env}"
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
      "arn:aws:s3:::${var.frontend_bucket}-${var.env}/*"
    ]
  }
}

resource "aws_s3_bucket" "frontend" {
  bucket = "${var.frontend_bucket}-${var.env}"

  tags = merge(
    local.tags, 
    {
      Name = "${local.prefix}-frontend-bucket"
    }
  )
}

resource "aws_s3_bucket_policy" "allow_access_from_public" {
  bucket = aws_s3_bucket.frontend.bucket
  policy = data.aws_iam_policy_document.frontend_bucket_policy.json
}

resource "aws_s3_bucket_acl" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket
  acl = var.bucket_acl
}

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket

  versioning_configuration {
    status = "Enabled"
  }
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
