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

output "database_subnet_group" {
    value       = module.vpc.database_subnet_group
}

output "database_security_group_id" {
    value       = module.postgres_sg.security_group_id
}

output "redis_subnet_group" {
    value       = module.vpc.elasticache_subnet_group
}
