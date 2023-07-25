locals {
  database_default_properties = {
    postgres = {
      username = var.database_username != "" ? var.database_username : "postgres"
      port     = 5432
    }
    mysql = {
      username = var.database_username != "" ? var.database_username : "root"
      port     = 3306
    }
  }
}

module "database" {
  source                    = "terraform-aws-modules/rds/aws"
  version                   = "~> 5.0"
  for_each                  = { for datastore_name, datastore_config in var.datastores : datastore_name => datastore_config if datastore_config.type == "sql" }
  identifier                = "${local.name_prefix}-${var.clp_zenv}-${each.value.engine}-${each.key}"
  db_name                   = each.value.name
  engine                    = each.value.engine
  engine_version            = each.value.version
  instance_class            = each.value.instance
  allocated_storage         = coalesce(try(each.value.database_allocated_storage, var.database_allocated_storage), var.database_allocated_storage)
  max_allocated_storage     = each.value.autoscaling == "enabled" ? try(each.value.database_max_allocated_storage, var.database_max_allocated_storage) : 0
  storage_encrypted         = true
  username                  = coalesce(try(each.value.database_username, local.database_default_properties[each.value.engine].username), local.database_default_properties[each.value.engine].username)
  password                  = random_password.database[each.key].result
  port                      = coalesce(try(each.value.database_port, local.database_default_properties[each.value.engine].port), local.database_default_properties[each.value.engine].port)
  create_db_option_group    = false
  create_db_parameter_group = false
  create_db_subnet_group    = true
  subnet_ids                = var.private_subnets
  vpc_security_group_ids    = var.security_groups
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "04:00-06:00"
  backup_retention_period   = 0
  tags                      = merge(try(each.value.tags, {}), var.standard_tags)
}

resource "random_password" "database" {
  for_each = { for datastore_name, datastore_config in var.datastores : datastore_name => datastore_config if datastore_config.type == "sql" }
  length   = 24
  special  = false
}

resource "aws_ssm_parameter" "database_connection_string" {
  for_each = { for datastore_name, datastore_config in var.datastores : datastore_name => datastore_config if datastore_config.type == "sql" }
  name     = "/${local.name_prefix}/${var.clp_zenv}/${each.value.engine}_connection_string-${each.key}"
  type     = "SecureString"
  value    = "${each.value.engine}://${module.database[each.key].db_instance_username}:${random_password.database[each.key].result}@${module.database[each.key].db_instance_endpoint}/${module.database[each.key].db_instance_name}"
  tags     = merge(try(each.value.tags, {}), var.standard_tags)
}
