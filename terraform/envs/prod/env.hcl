locals {
  aws_region         = "us-east-1"
  environment        = "prod"  # must match what's given to `copilot env init`
  application_name   = "chatbots"  # must match what's given to `copilot init`
  application_domain = "ocs-test.dimagi.com"
}
