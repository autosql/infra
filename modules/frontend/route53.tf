/*
data "aws_route53_zone" "this" {
  name = var.domain
}

resource "aws_route53_record" "this" {
  for_each = toset(var.bucket_names)

  zone_id = data.aws_route53_zone.this.zone_id

  name = "${each.value}.${var.env}"
  type = "A"

  alias {
    name = aws_s3_bucket.frontend["${each.key}"].website_domain
    zone_id = aws_s3_bucket.frontend["${each.key}"].hosted_zone_id
    evaluate_target_health = true
  }
}

*/
