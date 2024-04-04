output "redis_instance_endpoint_address" {
  value         = aws_elasticache_serverless_cache.redis.endpoint.0.address
}

output "redis_instance_endpoint_port" {
  value         = aws_elasticache_serverless_cache.redis.endpoint.0.port
}

output "redis_instance_address_secret_arn" {
  value         = aws_secretsmanager_secret.redis_instance_address.id
}
