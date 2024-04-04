variable "redis_subnet_group" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "ingress_cidr_blocks" {
  type = list(string)
}

variable "cache_engine_version" {
  type = string
  default = "7.1"
}

variable "node_type" {
  type = string
  default = "cache.t4g.micro"
}
