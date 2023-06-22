# ---------------------------------------------------
#   Web Application Firewall (WAF)
# ---------------------------------------------------
resource aws_wafv2_web_acl waf_acl {
  name        = "${var.name_prefix}-${var.clp_zenv}-WAF-ACL"
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

resource aws_wafv2_ip_set whitelisted_ips {
  name              = "${var.name_prefix}-${var.clp_zenv}-Whitelisted-IPs"
  description       = "Whitelisted IPs"
  scope             = "REGIONAL"  
  addresses         = var.whitelisted_ips
  ip_address_version = "IPV4"  
}
resource aws_wafv2_web_acl_association waf_acl_association {
  resource_arn = aws_lb.frontend.arn  
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}
