# configuration for terraform state management with s3 and dynamodb
remote_state {
  backend = "s3"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket         = "ocs-terraform-state-${get_aws_account_id()}"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "ocs-terraform-state-lock"
  }
}

# terraform versions and provider configuration
generate "provider" {
  path = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.40"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
provider "aws" {
  region = var.aws_region

  default_tags {
      tags = {
        copilot-environment: var.environment
        copilot-application: var.application_name
        terraform-managed: "true"
      }
  }
}
EOF
}

# application wide variables
generate "common_vars" {
  path = "common_vars.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
variable "environment" {
  type = string
}

variable "application_name" {
  type = string
}

variable "aws_region" {
  type = string
}
EOF
}

# load the module Terraform files from the relative path
terraform {
    # use 'basename' to drop the environment name from the path
    source = "${get_parent_terragrunt_dir()}/../modules/${basename(path_relative_to_include())}"
}
