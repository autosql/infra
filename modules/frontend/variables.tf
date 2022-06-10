variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "domain" {
  type = string
}

variable "bucket_names" {
  type = list
}

variable "bucket_acl" {
  type = string
  default = "private"
}

