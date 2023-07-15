# ---------------------------------------------------
#   Web Application Firewall (WAF)
# ---------------------------------------------------
resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "${local.name_prefix}-${var.clp_zenv}-WAF-ACL"
  description = "WAF ACL"

  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "whitelisted-ips-rule"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.whitelisted_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "WhitelistedIPsRule"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "block-non-whitelisted-ips"
    priority = 2

    action {
      block {}
    }

    statement {
      not_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.whitelisted_ips.arn
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BlockNonWhitelistedIPs"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "DefaultVisibility"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_ip_set" "whitelisted_ips" {
  name               = "${local.name_prefix}-${var.clp_zenv}-Whitelisted-IPs"
  description        = "Whitelisted IPs"
  scope              = "REGIONAL"
  addresses          = var.whitelisted_ips
  ip_address_version = "IPV4"
}

resource "aws_wafv2_web_acl_association" "acl_association" {
  for_each     = { for service_name, service_config in var.services : service_name => service_config if service_config.public == true }
  resource_arn = aws_lb.loadbalancers[each.key].arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}
