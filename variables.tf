variable "vpc_id" {}
variable "secrets" {}
variable "envvars" {}
variable "clp_zenv" {}
variable "clp_region" {}
variable "clp_account" {}
variable "account_id" {}
variable "ecr_region" {}
variable "domain_name" {}
variable "standard_tags" {}
variable "ecr_account_id" {}
variable "public_subnets" {}
variable "private_subnets" {}
variable "security_groups" {}
variable "s3_tf_artefacts" {}
variable "whitelisted_ips" {}
variable "mezmo_account_id" {}
variable "datastores" {
  type = map(object({
    name                           = string
    type                           = string
    engine                         = string
    version                        = string
    class                          = string
    instance                       = string
    autoscaling                    = string
    allocated_storage              = optional(number)
    database_max_allocated_storage = optional(number)
    database_username              = optional(string)
    database_port                  = optional(number)
    tags                           = optional(map(string))
  }))
  default = {
    postgres1 = {
      name        = "postgre"
      type        = "SQL"
      engine      = "postgres"
      version     = "15.2"
      class       = "burstable"
      instance    = "t4g.micro"
      autoscaling = "enabled"
    }
  }
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

variable "services" {
  description = "Map of service names and configurations"
  type = map(object({
    public               = bool
    type                 = string
    name                 = string
    cpu                  = number
    memory               = number
    service_discovery_id = string
    environment          = list(object({ name = string, value = string }))
  }))
  default = {
    frontend = {
      public               = true
      type                 = "frontend"
      name                 = "frontend"
      cpu                  = 256
      memory               = 512
      service_discovery_id = ""
      environment          = []
    },
    backend = {
      public               = true
      type                 = "non-frontend"
      name                 = "backend"
      cpu                  = 256
      memory               = 512
      service_discovery_id = ""
      environment = [
        {
          name  = "UPDATE_STATUSES_CRON"
          value = "*/10 * * * *"
        },
        {
          name  = "IS_WORKER"
          value = "1"
        },
      ]
    },
    runner = {
      public               = false
      type                 = "non-frontend"
      name                 = "runner"
      cpu                  = 256
      memory               = 512
      service_discovery_id = ""
      environment          = []
    }
  }
}