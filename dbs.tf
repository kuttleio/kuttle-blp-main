# All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
module "postgres" {
  source                    = "terraform-aws-modules/rds/aws"
  version                   = "~> 5.0"
  for_each                  = { for k, v in var.datastores : k => v if v.engine == "postgres" }
  identifier                = "${local.name_prefix}-${var.clp_zenv}-postgres-${each.key}"
  db_name                   = each.value.name
  engine                    = each.value.engine
  engine_version            = each.value.version
  instance_class            = each.value.instance
  allocated_storage         = try(each.value.allocated_storage, var.database_allocated_storage)
  max_allocated_storage     = each.value.autoscaling == "enabled" ? try(each.value.database_max_allocated_storage, var.database_max_allocated_storage) : 0
  storage_encrypted         = true
  username                  = try(each.value.database_username, var.database_username)
  password                  = random_password.postgres[each.key].result
  port                      = try(each.value.database_port, var.database_port)
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

resource "random_password" "postgres" {
  for_each = { for k, v in var.datastores : k => v if v.engine == "postgres" }
  length   = 24
  special  = false
}

resource "aws_ssm_parameter" "postgres_connection_string" {
  for_each = { for k, v in var.datastores : k => v if v.engine == "postgres" }
  name     = "/${local.name_prefix}/${var.clp_zenv}/postgres_connection_string-${each.key}"
  type     = "SecureString"
  value    = "postgres://${module.postgres[each.key].db_instance_username}:${random_password.postgres[each.key].result}@${module.postgres[each.key].db_instance_endpoint}/${module.postgres[each.key].db_instance_name}"
  tags     = merge(try(each.value.tags, {}), var.standard_tags)
}
