output "elasticache_replication_group_arn" {
  description = "The Amazon Resource Name (ARN) of the created ElastiCache Replication Group."
  value       = var.enabled ? aws_elasticache_replication_group.default[0].arn : ""
}

output "elasticache_replication_group_id" {
  description = "The ID of the ElastiCache Replication Group."
  value       = var.enabled ? aws_elasticache_replication_group.default[0].id : ""
}

output "elasticache_replication_group_primary_endpoint_address" {
  description = "The address of the endpoint for the primary node in the replication group."
  value       = var.enabled ? (var.cluster_mode_enabled && var.cluster_mode_num_node_groups > 0 ? aws_elasticache_replication_group.default[0].configuration_endpoint_address : aws_elasticache_replication_group.default[0].primary_endpoint_address) : ""
}

output "elasticache_replication_group_reader_endpoint_address" {
  description = "The address of the endpoint for the reader node in the replication group"
  value       = var.enabled ? (var.cluster_mode_enabled && var.cluster_mode_num_node_groups > 0 ? aws_elasticache_replication_group.default[0].configuration_endpoint_address : aws_elasticache_replication_group.default[0].reader_endpoint_address) : ""
}

output "elasticache_replication_group_member_clusters" {
  description = "The identifiers of all the nodes that are part of this replication group."
  value       = var.enabled ? aws_elasticache_replication_group.default[0].member_clusters : toset("")
}

output "elasticache_parameter_group_id" {
  description = "The ElastiCache parameter group name."
  value       = var.enabled ? aws_elasticache_parameter_group.default[0].id : ""
}

output "elasticache_subnet_group_name" {
  description = "The name of the ElastiCache Subnet Group."
  value       = var.enabled ? aws_elasticache_subnet_group.default[0].name : ""
}