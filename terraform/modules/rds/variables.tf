variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "database_subnet_group" {
  type = string
}

variable "database_security_group_id" {
  type = string
}

variable "ingress_cidr_blocks" {
  type = list(string)
}
