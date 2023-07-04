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
variable datastores {
    type = list(object({
        name        = string
        engine      = string
        version     = string
        instance    = string
    }))
}
variable "database_allocated_storage" {
    default = "20"
}
variable "database_max_allocated_storage" {
    default = "100"
}
variable "database_port" {
    default = "5432"
}
variable "database_username" {
    default = "kuttle"
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
