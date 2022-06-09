# ----- s3 bucket

output "bucket_domain_name" {
  value = aws_s3_bucket.frontend.bucket_domain_name
}

output "bucket_regional_domain_name" {
  value = aws_s3_bucket.frontend.bucket_regional_domain_name
}

## ----- S3 bucket website configuration
/*
output "website_domain" {
  value = aws_s3_bucket_website_configuration.frontend.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.frontend.website_endpoint
}
*/

# ----- cloudfront

output "domain_name" {
  value = aws_cloudfront_distribution.this.domain_name
}

output "hosted_zone_id" {
  value = aws_cloudfront_distribution.this.hosted_zone_id
}
