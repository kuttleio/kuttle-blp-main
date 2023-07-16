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
    for_each = aws_wafv2_ip_set.whitelisted_ips
    content {
      name     = "whitelisted-ips-rule-${title(each.key)}"
      priority = 1

      action {
        allow {}
      }

      statement {
        ip_set_reference_statement {
          arn = each.value.arn
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
    for_each = aws_wafv2_ip_set.whitelisted_ips
    content {
      name     = "block-non-whitelisted-ips-${title(each.key)}"
      priority = 2

      action {
        block {}
      }

      statement {
        not_statement {
          statement {
            ip_set_reference_statement {
              arn = each.value.arn
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
  for_each           = var.whitelisted_ips
  name               = "${local.name_prefix}-${var.clp_zenv}-Whitelisted-${title(each.key)}"
  description        = "Whitelisted IPs"
  scope              = "REGIONAL"
  addresses          = each.value.addresses
  ip_address_version = "IPV4"
}

locals {
  acl_associations = flatten([
    for service_name, service_config in var.services : [
      for acl_name in keys(var.whitelisted_ips) : {
        service = service_name
        acl     = acl_name
      }
    ] if service_config.public == true
  ])
}

resource "aws_wafv2_web_acl_association" "acl_association" {
  for_each     = { for assoc in local.acl_associations : "${assoc.service}-${assoc.acl}" => assoc }
  resource_arn = aws_lb.loadbalancers[each.value.service].arn
  web_acl_arn  = aws_wafv2_web_acl.waf_acl[each.value.acl].arn
}
