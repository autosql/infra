variable "domain" {
  type = string
}

data "aws_route53_zone" "this" {
  name = var.domain
}

output "current_zone" {
  value = data.aws_route53_zone.this
}
