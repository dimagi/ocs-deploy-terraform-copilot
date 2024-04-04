output "vpc_id" {
  value         = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  value         = module.vpc.vpc_cidr_block
}

output "public_subnets" {
    value       = module.vpc.public_subnets
}

output "private_subnets" {
    value       = module.vpc.private_subnets
}

output "application_cidr_blocks" {
    value       = setunion(module.vpc.public_subnets_cidr_blocks, module.vpc.private_subnets_cidr_blocks)
}

output "database_subnet_group" {
    value       = module.vpc.database_subnet_group
}

output "elasticache_subnets" {
    value       = module.vpc.elasticache_subnets
}
