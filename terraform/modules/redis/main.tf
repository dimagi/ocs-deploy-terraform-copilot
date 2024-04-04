locals {
  name             = "${var.application_name}-${var.environment}-cache"
  param_group_name = "${local.name}-params"

  engine_log_group = "${local.name}-engine-logs"
  slow_log_group = "${local.name}-slow-logs"

   version_to_family_map = {
    "7.x" = "redis7"
    "7.0" = "redis7"
  }
}

# ElastiCache 'cluster' with cluster mode disabled (1 primary + 1 replica)
resource "aws_elasticache_replication_group" "redis" {
  engine                        = "redis"
  engine_version                = var.cache_engine_version
  node_type                     = var.node_type
  description                   = local.name
  replication_group_id          = local.name
  num_cache_clusters            = 2
  parameter_group_name          = local.param_group_name
  port                          = 6397
  automatic_failover_enabled    = true
  at_rest_encryption_enabled    = true
  auto_minor_version_upgrade    = true
  maintenance_window            = "sun:05:00-sun:09:00"
  snapshot_retention_limit      = 7
  snapshot_window               = "06:30-07:30"
  subnet_group_name             = var.redis_subnet_group
  security_group_ids            = [module.redis_sg.security_group_id]
  multi_az_enabled              = true
  apply_immediately             = true

  # log delivery configuration for engine logs
  log_delivery_configuration {
    destination      = "${local.engine_log_group}"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "engine-log"
  }

  # log delivery configuration for slow logs
  log_delivery_configuration {
    destination      = "${local.slow_log_group}"
    destination_type = "cloudwatch-logs"
    log_format       = "json"
    log_type         = "slow-log"
  }
}

# log group for redis engine logs
resource "aws_cloudwatch_log_group" "elasticache-engine-logs" {
  name = "${local.engine_log_group}"
}

# log group for redis slow logs
resource "aws_cloudwatch_log_group" "elasticache-slow-logs" {
  name = "${local.slow_log_group}"
}

# custom parameter group for redis
resource "aws_elasticache_parameter_group" "custom_parameter_group" {
  name   = "${local.param_group_name}"
  family = lookup(local.version_to_family_map, var.cache_engine_version)

  parameter {
    name = "maxmemory-policy"
    value = "allkeys-lru"
  }
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
  name                    = "db_instance_endpoint_arn"
  description             = "RDS database instance endpoint ARN"
}

resource "aws_secretsmanager_secret_version" "redis_instance_address" {
  secret_id     = aws_secretsmanager_secret.redis_instance_address.id
  secret_string = aws_elasticache_replication_group.redis.primary_endpoint_address
}
