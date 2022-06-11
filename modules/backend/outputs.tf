output "repository_url" {
  value = aws_ecr_repository.this.repository_url
}

output "api_domain_name" {
  value = aws_route53_record.main.fqdn
}
