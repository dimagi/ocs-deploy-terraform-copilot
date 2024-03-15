output "db_instance_address" {
  value         = module.db.db_instance_address
}

output "db_instance_arn" {
  value         = module.db.db_instance_arn
}

output "db_instance_address_secret_arn" {
  value         = aws_secretsmanager_secret.db_instance_address.id
}

output "db_instance_master_user_secret_arn" {
  value         = module.db.db_instance_master_user_secret_arn
}
