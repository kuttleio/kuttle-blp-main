locals {
    engine          = "postgre"
    engine_version  = "9.5"
    cluster_family  = "postgre"
    cluster_size    = 1
    admin_user      = "kuttle"
    db_name         = "manifests"
    db_port         = 5432
    instance_type   = "db.t4g.medium"
}

module postgre {
    source  = "cloudposse/rds-cluster/aws"
    version = "~> 1.4.0"

    name            = "${local.name_prefix}-${var.clp_zenv}-PostgreSQL"
    engine          = local.engine
    cluster_family  = local.cluster_family
    cluster_size    = local.cluster_size
    admin_user      = local.admin_user
    admin_password  = random_password.postgre.result
    db_name         = local.db_name
    db_port         = local.db_port
    instance_type   = local.instance_type
    vpc_id          = var.vpc_id
    security_groups = var.security_groups
    subnets         = var.subnets
    tags            = var.standard_tags
}

resource random_password postgre {
    length  = 24
    special = false
}

resource aws_ssm_parameter postgre_connection_string {
    name    = "/${local.name_prefix}/${var.clp_zenv}/postgre_connection_string"
    type    = "SecureString"
    value   = "postgres://${module.postgre.master_username}:${random_password.postgre.result}@${module.postgre.endpoint}/${module.postgre.database_name}"
    tags    = var.standard_tags
}

# ---------------------------------------------------
#   DB Postgre - Outputs
# ---------------------------------------------------
output db_name {
    value       = module.postgre.database_name
    description = "DB name"
}

output db_master_username {
    value       = module.postgre.master_username
    description = "DB master username"
    sensitive   = true
}

output db_cluster_identifier {
    value       = module.postgre.cluster_identifier
    description = "Cluster Identifier"
}

output db_arn {
    value       = module.postgre.arn
    description = "RDS Cluster ARN"
}

output db_endpoint {
    value       = module.postgre.endpoint
    description = "RDS DNS endpoint"
}

output db_reader_endpoint {
    value       = module.postgre.reader_endpoint
    description = "RDS ReadOnly endpoint"
}

output db_master_host {
    value       = module.postgre.master_host
    description = "DB Master hostname"
}

output db_replicas_host {
    value       = module.postgre.replicas_host
    description = "Replicas hostname"
}
