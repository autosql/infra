# ----- Route Zone
data "aws_route53_zone" "this" {
  name = var.domain
}

# ----- Main Record
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.this.id

  name = "${local.domain_name}"
  type = "A"
  ttl = "300"
  records = [aws_eip.proxy.public_ip]

}

# ----- ACM Certificate
resource "aws_acm_certificate" "this" {
  domain_name = "${local.domain_name}"
  validation_method = "DNS"
}

resource "aws_route53_record" "this" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.this.id
}

resource "aws_acm_certificate_validation" "dns_validation" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [for record in aws_route53_record.this : record.fqdn]
}
