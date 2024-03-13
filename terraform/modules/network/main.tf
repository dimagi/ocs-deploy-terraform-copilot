data "aws_availability_zones" "available" {}

locals {
  name    = "${var.application_name}-${var.environment}"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    copilot-environment: var.environment
    copilot-application: var.application_name
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.name
  cidr = local.vpc_cidr

  azs              = local.azs
  public_subnets   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k)]
  private_subnets  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 4)]
  database_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 8)]
  elasticache_subnets = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 12)]

  create_database_subnet_group = true
  database_subnet_group_name = "${local.name}-postgres-subnet-group"
  create_elasticache_subnet_group = true

  tags = local.tags
}

# TODO: move this to the RDS module
module "postgres_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "~> 5.0"

  name        = "${local.name}-postgres-security-group"
  description = "PostgreSQL security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = setunion(module.vpc.public_subnets_cidr_blocks, module.vpc.private_subnets_cidr_blocks)
  tags = local.tags
}
