output "bucket_domain_name" {
  value = aws_s3_bucket.frontend.bucket_domain_name
}

output "website_domain" {
  value = aws_s3_bucket.frontend.website_domain
}

output "website_endpoint" {
  value = aws_s3_bucket.frontend.website_endpoint
}
