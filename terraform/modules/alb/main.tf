locals {
  name    = "${var.application_name}-${var.environment}-alb"

  tags = {
    copilot-environment: var.environment
    copilot-application: var.application_name
  }
}

module "alb" {
  source = "terraform-aws-modules/alb/aws"

  name    = local.name
  vpc_id  = var.vpc_id
  subnets = var.subnets

  # TODO: WAF: web_acl_arn

  # Security Group
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = var.egress_cidr_block
    }
  }

  access_logs = {
    bucket = module.log_bucket.s3_bucket_id
    prefix = "access-logs"
  }

  listeners = {
    http = {
      port               = 80
      protocol           = "HTTP"
      fixed_response     = {
        content_type = "text/plain"
        message_body = "Hello, World"
        status_code  = "200"
      }
    }
  }
#     ex-http-https-redirect = {
#       port     = 80
#       protocol = "HTTP"
#       redirect = {
#         port        = "443"
#         protocol    = "HTTPS"
#         status_code = "HTTP_301"
#       }
#     }
#     ex-https = {
#       port            = 443
#       protocol        = "HTTPS"
#       certificate_arn = var.certificate_arn
#     }
#
#     forward = {
#       target_group_key = "ex-instance"
#     }
#   }

#   target_groups = {
#     ex-instance = {
#       name_prefix      = "h1"
#       protocol         = "HTTP"
#       port             = 80
#       target_type      = "instance"
#     }
#   }

  tags = local.tags
}


module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.0"

  bucket_prefix = "${local.name}-logs-"
  acl           = "log-delivery-write"

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  attach_deny_insecure_transport_policy = true
  attach_require_latest_tls_policy      = true

  tags = local.tags
}
