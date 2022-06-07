variable "app" {
  type = string
}

variable "region" {
  type = string
  default = "ap-northeast-2"
}

variable "az" {
  type = list(string)
  default = ["${var.region}a", "${var.region}b"]
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnets" {
  type = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
