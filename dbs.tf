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

# locals {
#     engine          = "postgres"
#     engine_version  = "15.3"
#     cluster_family  = "postgres15"
#     cluster_size    = 1
#     admin_user      = "kuttle"
#     db_name         = "manifests"
#     db_port         = 5432
#     instance_type   = "db.t4g.micro"
# }

# module postgre {
#     source  = "cloudposse/rds-cluster/aws"
#     version = "~> 1.4.0"

#     name            = "${local.name_prefix}-${var.clp_zenv}-PostgreSQL"
#     engine          = local.engine
#     cluster_family  = local.cluster_family
#     cluster_size    = local.cluster_size
#     admin_user      = local.admin_user
#     admin_password  = random_password.postgre.result
#     db_name         = local.db_name
#     db_port         = local.db_port
#     instance_type   = local.instance_type
#     vpc_id          = var.vpc_id
#     security_groups = var.security_groups
#     subnets         = var.private_subnets
#     tags            = var.standard_tags
# }

# resource random_password postgre {
#     length  = 24
#     special = false
# }

# resource aws_ssm_parameter postgre_connection_string {
#     name    = "/${local.name_prefix}/${var.clp_zenv}/postgre_connection_string"
#     type    = "SecureString"
#     value   = "postgres://${module.postgre.master_username}:${random_password.postgre.result}@${module.postgre.endpoint}/${module.postgre.database_name}"
#     tags    = var.standard_tags
# }

# # ---------------------------------------------------
# #   DB Postgre - Outputs
# # ---------------------------------------------------
# output db_name {
#     value       = module.postgre.database_name
#     description = "DB name"
# }

# output db_master_username {
#     value       = module.postgre.master_username
#     description = "DB master username"
#     sensitive   = true
# }

# output db_cluster_identifier {
#     value       = module.postgre.cluster_identifier
#     description = "Cluster Identifier"
# }

# output db_arn {
#     value       = module.postgre.arn
#     description = "RDS Cluster ARN"
# }

# output db_endpoint {
#     value       = module.postgre.endpoint
#     description = "RDS DNS endpoint"
# }

# output db_reader_endpoint {
#     value       = module.postgre.reader_endpoint
#     description = "RDS ReadOnly endpoint"
# }

# output db_master_host {
#     value       = module.postgre.master_host
#     description = "DB Master hostname"
# }

# output db_replicas_host {
#     value       = module.postgre.replicas_host
#     description = "Replicas hostname"
# }


module postgres {
    source  = "terraform-aws-modules/rds/aws"
    version = "~> 5.0"

    identifier                 = "${local.name_prefix}-${var.clp_zenv}-PostgreSQL"
    engine                     = local.engine
    engine_version             = local.engine_version
    family                     = local.family
    major_engine_version       = local.major_engine_version
    instance_class             = local.instance_class
    allocated_storage          = local.allocated_storage
    db_name                    = local.db_name
    username                   = local.username
    password                   = random_password.postgres.result
    port                       = local.port
    create_db_option_group     = false
    create_db_parameter_group  = false
    db_subnet_group_name       = var.private_subnets
    vpc_security_group_ids     = var.security_groups
    maintenance_window         = "Sun:00:00-Sun:03:00"
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
