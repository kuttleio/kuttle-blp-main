# ---------------------------------------------------
#   Web Application Firewall (WAF)
# ---------------------------------------------------
# Web Application Firewall (WAF)
resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "${local.name_prefix}-${var.clp_zenv}-WAF-ACL"
  description = "WAF ACL"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "allow-whitelisted-ips"
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
      metric_name                = "BlockNonWhitelistedIPsRule"
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
  addresses          = var.ipwhitelist
  ip_address_version = "IPV4"
}

resource "aws_wafv2_web_acl_association" "acl_association" {
  for_each     = { for service in local.services : service.name => service if service.public }
  resource_arn = aws_lb.loadbalancers[each.value.name].arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}
