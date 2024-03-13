locals {
    env_vars    = read_terragrunt_config(find_in_parent_folders("env.hcl"))
    environment = local.env_vars.locals.environment
}

inputs = {
  aws_region        = local.env_vars.locals.aws_region
  environment       = local.environment
  application_name  = local.env_vars.locals.application_name
}
