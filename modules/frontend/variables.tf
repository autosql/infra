variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "frontend_bucket" {
  type = string
}

variable "bucket_acl" {
  type = string
  default = "private"
}

