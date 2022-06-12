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

variable "region" {
  type = string
}

# ----- VPC

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list
}

# ----- RDS

variable "instance_type" {
  type = string
}

variable "database_port" {
  type = number
}

variable "MYSQL_USER" {
  type = string
}

variable "MYSQL_PASSWORD" {
  type = string
}
