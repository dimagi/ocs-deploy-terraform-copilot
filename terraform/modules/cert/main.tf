locals {
  domain = var.application_domain

  # Removing trailing dot from domain - just to be sure :)
  domain_name = trimsuffix(local.domain, ".")

  # get top level domain
  domain_split = split(".", local.domain_name)
  domain_split_len = length(local.domain_split)
  top_level_domain = join(".", slice(local.domain_split, local.domain_split_len - 2, local.domain_split_len))
}

module "acm" {
  source = "terraform-aws-modules/acm/aws"

  providers = {
    aws = aws
  }

  domain_name = local.domain_name
  zone_id     = data.cloudflare_zone.this.id

  create_route53_records  = false
  validation_method       = "DNS"
  validation_record_fqdns = cloudflare_record.validation[*].hostname
}

resource "cloudflare_record" "validation" {
  count = length(module.acm.distinct_domain_names)

  zone_id = data.cloudflare_zone.this.id
  name    = element(module.acm.validation_domains, count.index)["resource_record_name"]
  type    = element(module.acm.validation_domains, count.index)["resource_record_type"]
  value   = trimsuffix(element(module.acm.validation_domains, count.index)["resource_record_value"], ".")
  ttl     = 60
  proxied = false

  allow_overwrite = true
}

data "cloudflare_zone" "this" {
  name = local.top_level_domain
}
