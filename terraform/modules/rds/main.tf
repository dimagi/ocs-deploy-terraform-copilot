locals {
  name    = "${var.application_name}-${var.environment}-postgres"
}

module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = local.name

  engine               = "postgres"
  engine_version       = "16.1"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = "db.t4g.small"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true  # default is true

  db_name  = var.db_name
  username = var.db_username
  port     = 5432

  auto_minor_version_upgrade = true

  manage_master_user_password                       = true  # default is true
  manage_master_user_password_rotation              = true
  master_user_password_rotate_immediately           = false
  master_user_password_rotation_schedule_expression = "rate(60 days)"

  multi_az               = true
  db_subnet_group_name   = var.database_subnet_group
  vpc_security_group_ids = [var.database_security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = 7
  deletion_protection     = true

  parameters = [
    {
      name  = "autovacuum"
      value = 1
    },
    {
      name  = "client_encoding"
      value = "utf8"
    }
  ]
}

module "postgres_sg" {
  source  = "terraform-aws-modules/security-group/aws//modules/postgresql"
  version = "~> 5.0"

  name        = "${local.name}-security-group"
  description = "PostgreSQL security group"
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = var.ingress_cidr_blocks
}

# put the db_instance_address in a secret for reference in other resources
resource "aws_secretsmanager_secret" "db_instance_address" {
  name                    = "db_instance_endpoint_arn"
  description             = "RDS database instance endpoint ARN"
}

resource "aws_secretsmanager_secret_version" "db_instance_address" {
  secret_id     = aws_secretsmanager_secret.db_instance_address.id
  secret_string = module.db.db_instance_address
}
