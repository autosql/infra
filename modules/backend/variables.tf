# ----- Common

variable "app" {
  type = string
}

variable "env" {
  type = string
}

variable "domain" {
  type = string
}

# ----- Application Port

variable "host_port" {
  type = number
}

variable "container_port" {
  type = number
}

# ----- VPC

variable "vpc_id" {
  type = string
}

