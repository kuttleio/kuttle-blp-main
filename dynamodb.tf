locals {
  dynamodb_defaults = {
    billing_mode                          = "PROVISIONED"
    table_class                           = "STANDARD"
    hash_key                              = null
    range_key                             = null
    attributes                            = []
    read_capacity                         = 5
    write_capacity                        = 5
    server_side_encryption_enabled        = true
    global_secondary_indexes              = []
    deletion_protection_enabled           = false
    ignore_changes_global_secondary_index = false
    autoscaling_read_enabled              = false
    autoscaling_read_scale_in_cooldown    = 50
    autoscaling_read_scale_out_cooldown   = 40
    autoscaling_read_target_value         = 45
    autoscaling_read_max_capacity         = 10
    autoscaling_write_enabled             = false
    autoscaling_write_scale_in_cooldown   = 50
    autoscaling_write_scale_out_cooldown  = 40
    autoscaling_write_target_value        = 45
    autoscaling_write_max_capacity        = 10
    autoscaling_indexes                   = {}
    stream_enabled                        = false
    stream_view_type                      = "NEW_AND_OLD_IMAGES"
    ttl_enabled                           = false
    ttl_attribute_name                    = ""
    point_in_time_recovery_enabled        = false
    tags                                  = {}
  }

  dynamodb_map = {
    for k, v in lookup(var.datastores, "dynamodb", {}) : k => {
      "table_name"                            = v.table_name
      "billing_mode"                          = try(coalesce(lookup(v, "billing_mode", null), local.dynamodb_defaults.billing_mode), local.dynamodb_defaults.billing_mode)
      "table_class"                           = try(coalesce(lookup(v, "table_class", null), local.dynamodb_defaults.table_class), local.dynamodb_defaults.table_class)
      "hash_key"                              = try(coalesce(lookup(v, "hash_key", null), local.dynamodb_defaults.hash_key), local.dynamodb_defaults.hash_key)
      "range_key"                             = try(coalesce(lookup(v, "range_key", null), local.dynamodb_defaults.range_key), local.dynamodb_defaults.range_key)
      "attributes"                            = try(coalesce(lookup(v, "attributes", null), local.dynamodb_defaults.attributes), local.dynamodb_defaults.attributes)
      "read_capacity"                         = try(coalesce(lookup(v, "read_capacity", null), local.dynamodb_defaults.read_capacity), local.dynamodb_defaults.read_capacity)
      "write_capacity"                        = try(coalesce(lookup(v, "write_capacity", null), local.dynamodb_defaults.write_capacity), local.dynamodb_defaults.write_capacity)
      "server_side_encryption_enabled"        = try(coalesce(lookup(v, "server_side_encryption_enabled", null), local.dynamodb_defaults.server_side_encryption_enabled), local.dynamodb_defaults.server_side_encryption_enabled)
      "global_secondary_indexes"              = try(coalesce(lookup(v, "global_secondary_indexes", null), local.dynamodb_defaults.global_secondary_indexes), local.dynamodb_defaults.global_secondary_indexes)
      "deletion_protection_enabled"           = try(coalesce(lookup(v, "deletion_protection_enabled", null), local.dynamodb_defaults.deletion_protection_enabled), local.dynamodb_defaults.deletion_protection_enabled)
      "ignore_changes_global_secondary_index" = try(coalesce(lookup(v, "ignore_changes_global_secondary_index", null), local.dynamodb_defaults.ignore_changes_global_secondary_index), local.dynamodb_defaults.ignore_changes_global_secondary_index)
      "autoscaling_read_enabled"              = try(coalesce(lookup(v, "autoscaling_read_enabled", null), local.dynamodb_defaults.autoscaling_read_enabled), local.dynamodb_defaults.autoscaling_read_enabled)
      "autoscaling_read_scale_in_cooldown"    = try(coalesce(lookup(v, "autoscaling_read_scale_in_cooldown", null), local.dynamodb_defaults.autoscaling_read_scale_in_cooldown), local.dynamodb_defaults.autoscaling_read_scale_in_cooldown)
      "autoscaling_read_scale_out_cooldown"   = try(coalesce(lookup(v, "autoscaling_read_scale_out_cooldown", null), local.dynamodb_defaults.autoscaling_read_scale_out_cooldown), local.dynamodb_defaults.autoscaling_read_scale_out_cooldown)
      "autoscaling_read_target_value"         = try(coalesce(lookup(v, "autoscaling_read_target_value", null), local.dynamodb_defaults.autoscaling_read_target_value), local.dynamodb_defaults.autoscaling_read_target_value)
      "autoscaling_read_max_capacity"         = try(coalesce(lookup(v, "autoscaling_read_max_capacity", null), local.dynamodb_defaults.autoscaling_read_max_capacity), local.dynamodb_defaults.autoscaling_read_max_capacity)
      "autoscaling_write_enabled"             = try(coalesce(lookup(v, "autoscaling_write_enabled", null), local.dynamodb_defaults.autoscaling_write_enabled), local.dynamodb_defaults.autoscaling_write_enabled)
      "autoscaling_write_scale_in_cooldown"   = try(coalesce(lookup(v, "autoscaling_write_scale_in_cooldown", null), local.dynamodb_defaults.autoscaling_write_scale_in_cooldown), local.dynamodb_defaults.autoscaling_write_scale_in_cooldown)
      "autoscaling_write_scale_out_cooldown"  = try(coalesce(lookup(v, "autoscaling_write_scale_out_cooldown", null), local.dynamodb_defaults.autoscaling_write_scale_out_cooldown), local.dynamodb_defaults.autoscaling_write_scale_out_cooldown)
      "autoscaling_write_target_value"        = try(coalesce(lookup(v, "autoscaling_write_target_value", null), local.dynamodb_defaults.autoscaling_write_target_value), local.dynamodb_defaults.autoscaling_write_target_value)
      "autoscaling_write_max_capacity"        = try(coalesce(lookup(v, "autoscaling_write_max_capacity", null), local.dynamodb_defaults.autoscaling_write_max_capacity), local.dynamodb_defaults.autoscaling_write_max_capacity)
      "autoscaling_indexes"                   = merge(coalesce(lookup(v, "autoscaling_indexes", null), local.dynamodb_defaults.autoscaling_indexes), local.dynamodb_defaults.autoscaling_indexes)
      "ttl_enabled"                           = try(coalesce(lookup(v, "ttl_enabled", null), local.dynamodb_defaults.ttl_enabled), local.dynamodb_defaults.ttl_enabled)
      "ttl_attribute_name"                    = try(coalesce(lookup(v, "ttl_attribute_name", null), local.dynamodb_defaults.ttl_attribute_name), local.dynamodb_defaults.ttl_attribute_name)
      "stream_enabled"                        = try(coalesce(lookup(v, "stream_enabled", null), local.dynamodb_defaults.stream_enabled), local.dynamodb_defaults.stream_enabled)
      "stream_view_type"                      = try(coalesce(lookup(v, "stream_view_type", null), local.dynamodb_defaults.stream_view_type), local.dynamodb_defaults.stream_view_type)
      "point_in_time_recovery_enabled"        = try(coalesce(lookup(v, "point_in_time_recovery_enabled", null), local.dynamodb_defaults.point_in_time_recovery_enabled), local.dynamodb_defaults.point_in_time_recovery_enabled)
      "tags"                                  = merge(merge(coalesce(lookup(v, "tags", null), {}), local.dynamodb_defaults.tags), var.standard_tags)
    } if coalesce(lookup(v, "create", true), true)
  }
}

module "dynamodb_table" {
  source                         = "terraform-aws-modules/dynamodb-table/aws"
  version                        = "~> 4.0.0"
  for_each                       = local.dynamodb_map
  name                           = each.value.table_name
  table_class                    = each.value.table_class
  hash_key                       = each.value.hash_key
  range_key                      = each.value.range_key
  billing_mode                   = each.value.billing_mode
  write_capacity                 = each.value.billing_mode == "PROVISIONED" ? each.value.write_capacity : null
  read_capacity                  = each.value.billing_mode == "PROVISIONED" ? each.value.read_capacity : null
  server_side_encryption_enabled = each.value.server_side_encryption_enabled
  attributes                     = each.value.attributes
  global_secondary_indexes       = each.value.global_secondary_indexes
  deletion_protection_enabled    = each.value.deletion_protection_enabled
  point_in_time_recovery_enabled = each.value.point_in_time_recovery_enabled
  stream_enabled                 = each.value.stream_enabled
  stream_view_type               = each.value.stream_enabled ? each.value.stream_view_type : null
  autoscaling_enabled            = each.value.billing_mode == "PROVISIONED" && (each.value.autoscaling_read_enabled || each.value.autoscaling_write_enabled) ? true : false
  autoscaling_read = each.value.autoscaling_read_enabled ? {
    scale_in_cooldown  = each.value.autoscaling_read_scale_in_cooldown
    scale_out_cooldown = each.value.autoscaling_read_scale_out_cooldown
    target_value       = each.value.autoscaling_read_target_value
    max_capacity       = each.value.autoscaling_read_max_capacity
  } : {}
  autoscaling_write = each.value.autoscaling_write_enabled ? {
    scale_in_cooldown  = each.value.autoscaling_write_scale_in_cooldown
    scale_out_cooldown = each.value.autoscaling_write_scale_out_cooldown
    target_value       = each.value.autoscaling_write_target_value
    max_capacity       = each.value.autoscaling_write_max_capacity
  } : {}
  autoscaling_indexes = length(each.value.autoscaling_indexes) > 0 ? each.value.autoscaling_indexes : {}
  tags                = each.value.tags
}
