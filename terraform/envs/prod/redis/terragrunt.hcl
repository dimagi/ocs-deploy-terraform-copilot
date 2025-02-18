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

inputs = {
  vpc_id                     = dependency.network.outputs.vpc_id
  ingress_cidr_blocks        = dependency.network.outputs.application_cidr_blocks
  redis_subnet_group         = dependency.network.outputs.elasticache_subnet_group
}
