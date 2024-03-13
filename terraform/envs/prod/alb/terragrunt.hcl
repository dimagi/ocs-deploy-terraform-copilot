include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_terragrunt_dir()}/../../_env/common.hcl"
  expose = true
}

dependency "network" {
  config_path = "../network"
}

dependency "cert" {
    config_path = "../cert"
}

inputs = {
  vpc_id            = dependency.network.outputs.vpc_id
  subnets           = dependency.network.outputs.public_subnets
  egress_cidr_block = dependency.network.outputs.vpc_cidr_block
  certificate_arn   = dependency.cert.outputs.acm_certificate_arn
}
