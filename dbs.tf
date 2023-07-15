# All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
module "postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 5.0"

  count                     = length(var.datastores)
  identifier                = "${local.name_prefix}-${var.clp_zenv}-postgres-${count.index}"
  db_name                   = var.datastores[count.index].name
  engine                    = var.datastores[count.index].engine
  engine_version            = var.datastores[count.index].version
  instance_class            = var.datastores[count.index].instance
  allocated_storage         = var.database_allocated_storage
  max_allocated_storage     = var.database_max_allocated_storage
  storage_encrypted         = true
  username                  = var.database_username
  password                  = random_password.postgres[count.index].result
  port                      = var.database_port
  create_db_option_group    = false
  create_db_parameter_group = false
  create_db_subnet_group    = true
  subnet_ids                = var.private_subnets
  vpc_security_group_ids    = var.security_groups
  maintenance_window        = "Mon:00:00-Mon:03:00"
  backup_window             = "04:00-06:00"
  backup_retention_period   = 0
  tags                      = var.standard_tags
}

resource "random_password" "postgres" {
  count   = length(var.datastores)
  length  = 24
  special = false
}

resource "aws_ssm_parameter" "postgres_connection_string" {
  count = length(var.datastores)
  name  = "/${local.name_prefix}/${var.clp_zenv}/postgres_connection_string-${count.index}"
  type  = "SecureString"
  value = "postgres://${module.postgres[count.index].db_instance_username}:${random_password.postgres[count.index].result}@${module.postgres[count.index].db_instance_endpoint}/${module.postgres[count.index].db_instance_name}"
  tags  = var.standard_tags
}
