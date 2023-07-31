variable "clp_wenv" {
  default = "test"
}

variable "standard_tags" {
  default = {}
}

variable "caches" {
  type = map(object({
    name                       = string
    type                       = string
    engine                     = string
    engine_version             = optional(string)
    port                       = optional(number)
    security_group_ids         = list(string)
    num_cache_clusters         = optional(number)
    node_type                  = optional(string)
    automatic_failover_enabled = optional(bool)
    apply_immediately          = optional(bool)
    maintenance_window         = optional(string)
    snapshot_window            = optional(string)
    snapshot_retention_limit   = optional(number)
    tags                       = optional(map(string))
  }))
  default = {
    cache = {
      name               = "cache"
      type               = "cache"
      engine             = "redis"
      security_group_ids = ["sg-0a0a0a0a0a0a0a0a0"]
      node_type          = "cache.t4g.micro"
    }
  }
}

variable "private_subnets" {
  type = list(string)
  default = [
    "subnet-0a0a0a0a0a0a0a0a0",
    "subnet-0a0a0a0a0a0a0a0a0",
    "subnet-0a0a0a0a0a0a0a0a0",
  ]
}

locals {
  name_prefix = "region1-testenv"
  database_default_properties = {
    redis = {
      engine_version             = "5.0.5"
      port                       = 6379
      node_type                  = "cache.t3.micro"
      num_cache_clusters         = 1
      automatic_failover_enabled = false
      apply_immediately          = false
      maintenance_window         = "fri:08:00-fri:09:00"
      snapshot_window            = "06:30-07:30"
      snapshot_retention_limit   = 0
    }
  }
}

module "cache" {
  source                        = "../"
  for_each                      = { for cache_name, cache_config in var.caches : cache_name => cache_config if cache_config.type == "cache" }
  replication_group_id          = "${local.name_prefix}-${var.clp_wenv}"
  replication_group_description = "ElastiCache replication group for ${local.name_prefix}-${var.clp_wenv}"
  engine                        = each.value.engine
  port                          = coalesce(each.value.port, local.database_default_properties[each.value.engine].port)
  engine_version                = coalesce(each.value.engine_version, local.database_default_properties[each.value.engine].engine_version)
  num_cache_clusters            = coalesce(each.value.num_cache_clusters, local.database_default_properties[each.value.engine].num_cache_clusters)
  node_type                     = coalesce(each.value.node_type, local.database_default_properties[each.value.engine].node_type)
  automatic_failover_enabled    = coalesce(each.value.automatic_failover_enabled, local.database_default_properties[each.value.engine].automatic_failover_enabled)
  security_group_ids            = each.value.security_group_ids
  subnet_ids                    = var.private_subnets
  apply_immediately             = coalesce(each.value.apply_immediately, false)
  maintenance_window            = coalesce(each.value.maintenance_window, local.database_default_properties[each.value.engine].maintenance_window)
  snapshot_window               = coalesce(each.value.snapshot_window, local.database_default_properties[each.value.engine].snapshot_window)
  snapshot_retention_limit      = coalesce(each.value.snapshot_retention_limit, local.database_default_properties[each.value.engine].snapshot_retention_limit)
  tags = merge(try(each.value.tags, {}), var.standard_tags, {
    Service          = "ElastiCache"
    ServiceComponent = "Redis"
  })
}