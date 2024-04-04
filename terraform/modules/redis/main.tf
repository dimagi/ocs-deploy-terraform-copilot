locals {
  name             = "${var.application_name}-${var.environment}-cache"
}

resource "aws_elasticache_serverless_cache" "redis" {
  engine                   = "redis"
  name                     = "${local.name}"
  daily_snapshot_time      = "09:00"
  description              = "${local.name}"
  major_engine_version     = "${var.redis_major_engine_version}"
  snapshot_retention_limit = 1
  security_group_ids       = [module.redis_sg.security_group_id]
  subnet_ids               = var.redis_subnets
}

# Security group for redis
module "redis_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/redis"
  version = "~> 5.0"

  name        = "${local.name}-security-group"
  description = "Redis security group"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.ingress_cidr_blocks
}


# put the primary_endpoint_address in a secret for reference in other resources
resource "aws_secretsmanager_secret" "redis_instance_address" {
  name                    = "${local.name}_address"
  description             = "Redis instance endpoint address"
}

resource "aws_secretsmanager_secret_version" "redis_instance_address" {
  secret_id     = aws_secretsmanager_secret.redis_instance_address.id
  secret_string = aws_elasticache_serverless_cache.redis.endpoint.0.address
}
