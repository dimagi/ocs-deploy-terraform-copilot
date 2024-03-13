data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

locals {
  name    = "${var.application_name}-${var.environment}-postgres"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  tags = {
    copilot-environment: var.environment
    copilot-application: var.application_name
  }
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

  tags = local.tags
}
