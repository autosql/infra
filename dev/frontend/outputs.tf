# ----- s3 bucket
output "bucket_regional_domain_name" {
  value = module.frontend.bucket_regional_domain_name 
}

output "website_endpoints" {
  value = module.frontend.website_endpoints
}

## ----- S3 bucket website configuration
/*
output "website_domain" {
  value = module.frontend.website_domain 
}

output "website_endpoint" {
  value = module.frontend.website_endpoint 
}
*/
