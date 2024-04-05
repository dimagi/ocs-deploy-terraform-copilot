data "aws_caller_identity" "current" {}

locals {
  name       = "${var.application_name}-${var.environment}-repository"
  account-id = data.aws_caller_identity.current.account_id
}

module "ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = local.name

  create_lifecycle_policy           = true
  repository_lifecycle_policy       = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Keep last 30 images",
        selection = {
          tagStatus     = "tagged",
          tagPrefixList = ["v"],
          countType     = "imageCountMoreThan",
          countNumber   = 30
        },
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_force_delete = true
}
