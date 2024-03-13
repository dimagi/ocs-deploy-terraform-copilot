variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list
}

variable "egress_cidr_block" {
  type = string
}

variable "certificate_arn" {
  type = string
}
