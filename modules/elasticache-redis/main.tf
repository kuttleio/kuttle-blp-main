resource "aws_elasticache_parameter_group" "default" {
  count       = var.enabled ? 1 : 0
  name        = var.replication_group_id
  description = "Elasticache parameter group for ${var.replication_group_id}"
  family      = "redis${replace(var.engine_version, "/\\.[\\d]+$/", "")}"

  tags = var.tags

  lifecycle {
    ignore_changes = [
      description,
    ]
  }
}

resource "aws_elasticache_subnet_group" "default" {
  count       = var.enabled && length(var.subnet_ids) > 0 ? 1 : 0
  name        = var.replication_group_id
  description = "Elasticache subnet group for ${var.replication_group_id}"
  subnet_ids  = var.subnet_ids
  tags        = var.tags
}

resource "aws_elasticache_replication_group" "default" {
  count                      = var.enabled ? 1 : 0
  replication_group_id       = var.replication_group_id
  description                = var.replication_group_description
  engine                     = var.engine
  engine_version             = var.engine_version
  parameter_group_name       = aws_elasticache_parameter_group.default[0].name
  subnet_group_name          = aws_elasticache_subnet_group.default[0].name
  security_group_ids         = var.security_group_ids
  auth_token                 = var.transit_encryption_enabled ? var.auth_token : null
  node_type                  = var.node_type
  num_cache_clusters         = var.cluster_mode_enabled ? null : var.num_cache_clusters
  port                       = var.port
  automatic_failover_enabled = var.cluster_mode_enabled ? true : (var.automatic_failover_enabled && var.num_cache_clusters >= 2 ? true : false)
  multi_az_enabled           = var.multi_az_enabled
  maintenance_window         = var.maintenance_window
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  kms_key_id                 = var.at_rest_encryption_enabled ? var.kms_key_id : null
  transit_encryption_enabled = var.transit_encryption_enabled || var.auth_token != null
  snapshot_window            = var.snapshot_window
  snapshot_retention_limit   = var.snapshot_retention_limit
  num_node_groups            = var.cluster_mode_enabled ? var.cluster_mode_num_node_groups : null
  replicas_per_node_group    = var.cluster_mode_enabled ? var.cluster_mode_replicas_per_node_group : null
  apply_immediately          = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade || tonumber(split(".", replace(var.engine_version, "v", ""))[0]) >= 6
  tags                       = var.tags
}
