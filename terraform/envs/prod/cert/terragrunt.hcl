include "root" {
  path = find_in_parent_folders()
}

include "env" {
  path   = "${get_terragrunt_dir()}/../../_env/common.hcl"
  expose = true
}

inputs = {
  application_domain = include.env.locals.env_vars.locals.application_domain
}
