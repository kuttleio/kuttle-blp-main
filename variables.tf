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
    public      = bool
    name        = string
    cpu         = number
    memory      = number
    endpoint    = optional(string)
    command     = optional(list(string))
    environment = optional(list(object({ name = string, value = string })))
    secrets     = optional(list(object({ name = string, valueFrom = string })))
    tags        = optional(map(string))
    deploy = object({
      gitrepo        = string
      dockerfilepath = optional(string)
      method         = optional(string)
      branch         = optional(string)
      version        = optional(string)
    })
  }))
  default = {
    frontend = {
      public      = true
      name        = "frontend"
      cpu         = 256
      memory      = 512
      endpoint    = ""
      environment = []
      deploy = {
        gitrepo        = "kuttleio/frontend"
        dockerfilepath = "Dockerfile"
        method         = "from_branch"
        branch         = "master"
      }
    }
    backend = {
      public      = true
      name        = "backend"
      cpu         = 256
      memory      = 512
      endpoint    = "backend"
      environment = []
      deploy = {
        gitrepo        = "kuttleio/backend"
        dockerfilepath = "Dockerfile"
        method         = "from_branch"
        branch         = "master"
      }
    }
    runner = {
      public      = false
      name        = "runner"
      cpu         = 256
      memory      = 512
      endpoint    = ""
      environment = []
      deploy = {
        gitrepo        = "kuttleio/runner"
        dockerfilepath = "Dockerfile"
        method         = "from_branch"
        branch         = "master"
      }
    }
  }
}

variable "mongodb_atlas_org_id" {
  description = "MongoDB Atlas Organization ID"
  type        = string
  default     = ""
}

variable "auth_database_name" {
  description = "MongoDB Atlas Authentication Database Name"
  type        = string
  default     = "admin"
}

variable "mongodb_atlas" {
  description = "Map of MongoDB Atlas configurations"
  type = map(object({
    project_name = string
    cluster1 = optional(object({
      cluster_type                 = optional(string)
      provider_name                = optional(string)
      backing_provider_name        = optional(string)
      provider_region_name         = optional(string)
      provider_instance_size_name  = optional(string)
      mongo_db_major_version       = optional(string)
      auto_scaling_disk_gb_enabled = optional(bool)
      replication_specs = optional(map(object({
        num_shards      = optional(number)
        region_name     = optional(string)
        electable_nodes = optional(number)
        priority        = optional(number)
        read_only_nodes = optional(number)
      })))
    }))
    users = optional(list(string))
  }))
  default = {}
}

variable "vpn_ip_list" {
  description = "List of VPN IPs"
  type        = list(string)
  default     = []
}

variable "nat_public_ips" {
  description = "List of NAT Gateway IPs"
  type        = list(string)
  default     = []
}
