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

  dynamic "rule" {
    for_each = toset(var.ipwhitelist)
    content {
      name     = "whitelisted-ips-rule-${rule.value}"
      priority = 1

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = aws_wafv2_ip_set.whitelisted_ips[rule.key].arn
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "WhitelistedIPsRule"
        sampled_requests_enabled   = true
      }
    }
  }

  dynamic "rule" {
    for_each = toset(var.ipwhitelist)
    content {
      name     = "block-non-whitelisted-ips-${rule.value}"
      priority = 2

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            ip_set_reference_statement {
              arn = aws_wafv2_ip_set.whitelisted_ips[rule.key].arn
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
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "DefaultVisibility"
    sampled_requests_enabled   = true
  }
}

resource "aws_wafv2_ip_set" "whitelisted_ips" {
  for_each           = toset(var.ipwhitelist)
  name               = "${local.name_prefix}-${var.clp_zenv}-Whitelisted-${each.value}"
  description        = "Whitelisted IPs"
  scope              = "REGIONAL"
  addresses          = [each.key]
  ip_address_version = "IPV4"
}

resource "aws_wafv2_web_acl_association" "acl_association" {
  for_each     = { for service_name, service_config in var.services : service_name => service_config if service_config.public == true }
  resource_arn = aws_lb.loadbalancers[each.key].arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl.arn
}
