resource "aws_s3_bucket" "frontend" {
  for_each = toset(var.bucket_names)

  bucket = "${each.value}.${var.env}.${var.domain}" 

  force_destroy = true

  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-${each.value}-bucket"
    }
  )
}

resource "aws_s3_bucket_website_configuration" "frontend" {
  for_each = toset(var.bucket_names)

  bucket = aws_s3_bucket.frontend["${each.key}"].bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

  routing_rule {
    condition {
      key_prefix_equals = "index.html"
    }
    redirect {
      replace_key_prefix_with = "index.html"
    }
  }

}

data "aws_iam_policy_document" "bucket_policy" {
  for_each = toset(var.bucket_names)

  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type = "AWS"
    }
    resources = [
      "arn:aws:s3:::${aws_s3_bucket.frontend["${each.key}"].bucket}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_public" {
  for_each = toset(var.bucket_names)

  bucket = aws_s3_bucket.frontend["${each.key}"].bucket 
  policy = data.aws_iam_policy_document.bucket_policy["${each.key}"].json
}

resource "aws_s3_bucket_acl" "frontend" {
  for_each = toset(var.bucket_names)

  bucket = aws_s3_bucket.frontend["${each.key}"].bucket 
  acl = var.bucket_acl
}
