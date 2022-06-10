# ----- s3 bucket

output "bucket_regional_domain_name" {
  value = {
    for k, bucket in aws_s3_bucket.frontend : k => bucket.bucket_regional_domain_name
  }
}

output "website_endpoints" {
  value = {
    for k, bucket in aws_s3_bucket.frontend : k => bucket.website_endpoint
  }
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

