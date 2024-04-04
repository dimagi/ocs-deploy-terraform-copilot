variable "redis_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ingress_cidr_blocks" {
  type = list(string)
}

variable "redis_major_engine_version" {
  type = string
  default = "7"
}
