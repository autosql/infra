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
