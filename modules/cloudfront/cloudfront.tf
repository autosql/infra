variable "default_bucket" {
  type = string
  default = "landing"
}

data "aws_cloudfront_cache_policy" "optimized" {
  name = "Managed-CachingOptimized"
}
data "aws_cloudfront_cache_policy" "disable" {
  name = "Managed-CachingDisabled"
}

resource "aws_cloudfront_distribution" "this" {
  enabled = true
  aliases = ["${local.domain_name}"]

  dynamic "origin" {
    for_each = var.bucket_domain_names

    content {
      domain_name = origin.value
      origin_id = origin.key

      custom_origin_config {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "http-only"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.default_bucket

    cache_policy_id = data.aws_cloudfront_cache_policy.optimized.id

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  dynamic "ordered_cache_behavior" {
    for_each = {
      for k, val in var.bucket_domain_names :
      k => val
      if k != var.default_bucket
    }

    content {
      path_pattern = "/${ordered_cache_behavior.key}/*" 

      allowed_methods  = ["GET", "HEAD"]
      cached_methods   = ["GET", "HEAD"]
      target_origin_id = ordered_cache_behavior.key

      cache_policy_id = data.aws_cloudfront_cache_policy.disable.id

      viewer_protocol_policy = "allow-all"
      min_ttl                = 0
      default_ttl            = 3600
      max_ttl                = 86400
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  price_class = "PriceClass_200"

  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn = aws_acm_certificate.this.arn
    ssl_support_method       = "vip"
    minimum_protocol_version = "TLSv1"
  }

  tags = local.tags
}
