resource "aws_s3_bucket" "frontend" {
  bucket = "${var.frontend_bucket}-${var.env}"

  force_destroy = true

  tags = merge(
    local.tags,
    {
      Name = "${local.prefix}-frontend-bucket"
    }
  )
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
      "${aws_s3_bucket.frontend.arn}/landing/*",
      "${aws_s3_bucket.frontend.arn}/erd/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_public" {
  bucket = aws_s3_bucket.frontend.bucket
  policy = data.aws_iam_policy_document.frontend_bucket_policy.json
}

resource "aws_s3_bucket_acl" "frontend" {
  bucket = aws_s3_bucket.frontend.bucket
  acl = var.bucket_acl
}

