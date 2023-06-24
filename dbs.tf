# All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
locals {
    engine                  = "postgres"
    engine_version          = "14"
    family                  = "postgres14"
    major_engine_version    = "14"
    username                = "kuttle"
    db_name                 = "environments"
    port                    = 5432
    instance_class          = "db.t4g.micro"
    allocated_storage       = 20
}

module postgres {
    source  = "terraform-aws-modules/rds/aws"
    version = "~> 5.0"

    identifier                 = "${local.name_prefix}-${var.clp_zenv}-postgres"
    engine                     = local.engine
    engine_version             = local.engine_version
    family                     = local.family
    major_engine_version       = local.major_engine_version
    instance_class             = local.instance_class
    allocated_storage          = local.allocated_storage
    storage_encrypted          = true
    db_name                    = local.db_name
    username                   = local.username
    password                   = random_password.postgres.result
    port                       = local.port
    create_db_option_group     = false
    create_db_parameter_group  = false
    subnet_ids                 = var.private_subnets
    vpc_security_group_ids     = var.security_groups
    maintenance_window         = "Mon:00:00-Mon:03:00"
    backup_window              = "04:00-06:00"
    backup_retention_period    = 0
    tags                       = var.standard_tags
}

resource random_password postgres {
    length  = 24
    special = false
}

resource aws_ssm_parameter postgres_connection_string {
    name    = "/${local.name_prefix}/${var.clp_zenv}/postgres_connection_string"
    type    = "SecureString"
    value   = "postgres://${module.postgres.db_instance_username}:${random_password.postgres.result}@${module.postgres.db_instance_endpoint}/${local.db_name}"
    tags    = var.standard_tags
}
