variable "app" {
  type = string
}

variable "region" {
  type = string
}

variable "env" {
  type = string
}

variable "cloudfront_info" {
  type = map
}

variable "domain" {
  type = string
}

variable "route53_zone_id" {
  type = string
}

variable "app_dns_info" {
  type = map
}

variable "remove_record" {
  type = string
  default = "landing"
}
