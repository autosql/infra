# ----- s3 bucket

output "bucket_domain_name" {
  value = aws_s3_bucket.frontend.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.frontend.bucket_regional_domain_name
}

output "website_domain" {
  value = aws_s3_bucket.frontend.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket.frontend.website_endpoint
}

# ----- cloudfront

output "domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}
