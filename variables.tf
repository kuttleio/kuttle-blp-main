variable vpc_id {}
variable secrets {}
variable envvars {}
variable clp_zenv {}
variable clp_region {}
variable clp_account {}
variable account_id {}
variable ecr_region {}
variable domain_name {}
variable standard_tags {}
variable ecr_account_id {}
variable public_subnets {}
variable private_subnets {}
variable security_groups {}
variable s3_tf_artefacts {}
variable whitelisted_ips {}
variable mezmo_account_id {}
variable database_name {
    default = "environments"
}
variable database_engine_version {
    default = "14"
}
variable database_engine {
    default = "postgres"
}
variable database_instance_class {
    default = "db.t4g.micro" 
}

variable frontend_container_cpu {
    default = "256"
}
variable frontend_container_memory {
    default = "512"
}
variable backend_container_cpu {
    default = "256"
}
variable backend_container_memory {
    default = "512"
}
variable runner_container_cpu {
    default = "256"
}
variable runner_container_memory {
    default = "512"
}
