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

# ----- Application Variables

variable "host_port" {
  type = number
}

variable "container_port" {
  type = number
}

variable "container_spec_path" {
  type = string
}

variable "MYSQL_USERNAME" {
  type = string
}

variable "MYSQL_DATABASE" {
  type = string
}

# ----- VPC

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type = list
}

# ----- cluster

variable "desired_count" {
  type = number
}

# ----- AutoScaling

variable "min_capacity" {
  type = number
}

variable "max_capacity" {
  type = number
}

variable "scale_policy" {
  type = map(number)
}

# ----- Code Pipeline
variable "taskdef_path" {
  type = string
}

variable "appspec_path" {
  type = string
}
