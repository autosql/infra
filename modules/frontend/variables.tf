variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "domain" {
  type = string
}

variable "region" {
  type = string
}

# ----- Bucket

variable "bucket_names" {
  type = list
}

variable "bucket_acl" {
  type = string
  default = "private"
}


# ----- VPC

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list
}
