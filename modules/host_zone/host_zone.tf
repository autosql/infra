/*
resource "aws_route53_record" "cname" {
  for_each = var.app_dns_info

  zone_id = var.route53_zone_id
  name = "%{if var.env != "prod"}${var.env}.%{endif}%{if each.key != var.remove_record}${each.key}.%{endif}${var.domain}"
  type = "CNAME"

  set_identifier = "${var.env}-${each.key}"
  records = ["${each.value["name"]}%{if each.value["tier"] == "frontend" }/${each.value["path"]}/index.html%{endif}"]
}
*/

resource "aws_route53_record" "cloudfront" {
  zone_id = var.route53_zone_id
  name = "%{if var.env != "prod"}${var.env}.%{endif}${var.domain}"
  type = "A"

  alias {
    name = var.cloudfront_info["name"]
    zone_id = var.cloudfront_info["zone_id"]
    evaluate_target_health = true
  }
}
