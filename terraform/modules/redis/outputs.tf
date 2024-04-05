output "redis_instance_address" {
  value         = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "redis_instance_url_secret_arn" {
  value         = aws_secretsmanager_secret.redis_instance_url.id
}
