data "aws_region" "current" {}
data "aws_elb_service_account" "main" {}

data "aws_route53_zone" "main" {
  name = var.domain_name
}

data "aws_acm_certificate" "main" {
  domain      = "*.${var.domain_name}"
  statuses    = ["ISSUED"]
  most_recent = true
}

data "aws_ssm_parameter" "logdna_service_key" {
  name            = "/${local.name_prefix}/logdna_service_key"
  with_decryption = true
}

data "aws_ssm_parameter" "github_token" {
  name            = "/${local.name_prefix}/github_token"
  with_decryption = true
}
