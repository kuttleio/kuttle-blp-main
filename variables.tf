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
variable "ipwhitelist" {
  type = list(string)
  default = [
    "0.0.0.0/1",
    "128.0.0.0/1"
  ]
  validation {
    condition = alltrue([
      for ip in var.ipwhitelist : can(cidrnetmask(ip)) 
    ])
    error_message = "Invalid CIDR block format. Expected format: x.x.x.x/x"
  }
}
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
    database_allocated_storage     = optional(number)
    database_max_allocated_storage = optional(number)
    database_username              = optional(string)
    database_port                  = optional(number)
    tags                           = optional(map(string))
  }))
  default = {}
}
variable "database_allocated_storage" {
  type    = number
  default = 20
}
variable "database_max_allocated_storage" {
  type    = number
  default = 100
}
variable "database_port" {
  type    = number
  default = 5432
}
variable "database_username" {
  type    = string
  default = "kuttle"
}

variable "s3_buckets" {
  description = "Map of S3 buckets"
  type = map(object({
    versioning              = optional(map(string))
    block_public_acls       = optional(bool)
    block_public_policy     = optional(bool)
    ignore_public_acls      = optional(bool)
    restrict_public_buckets = optional(bool)
    attach_policy           = optional(bool)
    policy = optional(object(
      {
        principals = optional(list(string))
        actions    = optional(list(string))
      }
    ))
    policy_json      = optional(string)
    lifecycle_rule   = optional(list(any))
    object_ownership = optional(string)
    force_destroy    = optional(bool)
    tags             = optional(map(string))
  }))
  default = {}
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
    secrets              = optional(list(object({ name = string, valueFrom = string })))
    tags                 = optional(map(string))
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