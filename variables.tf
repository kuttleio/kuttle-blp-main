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

variable "ipwhitelist" {
  type    = list(string)
  default = ["0.0.0.0/1", "128.0.0.0/1"]
  validation {
    condition = alltrue([
      for ip in var.ipwhitelist : can(cidrnetmask(ip))
    ])
    error_message = "Invalid CIDR block format. Expected format: x.x.x.x/x"
  }
}
variable "mezmo_account_id" {}

variable "datastores" {
  type = object(
    {
      dynamodb = optional(map(object({
        table_name   = string
        billing_mode = optional(string)
        table_class  = optional(string)
        hash_key     = string
        range_key    = optional(string)
        attributes = list(object({
          name = string
          type = string
        }))
        read_capacity                  = optional(number)
        write_capacity                 = optional(number)
        server_side_encryption_enabled = optional(bool)
        deletion_protection_enabled    = optional(bool)
        global_secondary_indexes = optional(list(object({
          name                                  = string
          hash_key                              = string
          range_key                             = optional(string)
          write_capacity                        = optional(number)
          read_capacity                         = optional(number)
          projection_type                       = optional(string)
          non_key_attributes                    = optional(list(string))
          server_side_encryption_enabled        = optional(bool)
          stream_enabled                        = optional(bool)
          stream_view_type                      = optional(string)
          projection_non_key_attributes         = optional(list(string))
          projection_include                    = optional(bool)
          projection_include_type               = optional(string)
          projection_include_non_key_attributes = optional(list(string))
        })))
        ignore_changes_global_secondary_index = optional(bool)
        autoscaling_read_enabled              = optional(bool)
        autoscaling_read_scale_in_cooldown    = optional(number)
        autoscaling_read_scale_out_cooldown   = optional(number)
        autoscaling_read_target_value         = optional(number)
        autoscaling_read_max_capacity         = optional(number)
        autoscaling_write_enabled             = optional(bool)
        autoscaling_write_scale_in_cooldown   = optional(number)
        autoscaling_write_scale_out_cooldown  = optional(number)
        autoscaling_write_target_value        = optional(number)
        autoscaling_write_max_capacity        = optional(number)
        autoscaling_indexes = optional(map(object({
          read_max_capacity  = optional(number)
          read_min_capacity  = optional(number)
          write_max_capacity = optional(number)
          write_min_capacity = optional(number)
        })))
        stream_enabled                 = optional(bool)
        stream_view_type               = optional(string)
        ttl_enabled                    = optional(bool)
        ttl_attribute_name             = optional(string)
        point_in_time_recovery_enabled = optional(bool)
        tags                           = optional(map(string))
      })))
    }
  )
  default = {
    dynamodb = {}
  }
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
    services = {
      api = {
        public = true
        name = "api"
        endpoint = "api"
        cpu = 256
        memory = 512
        environment = []
        deploy = {
          gitrepo = "kuttleio/api"
          dockerfilepath = "Dockerfile"
          method = "from_branch"
          branch = "master"
        }
      }
      back = {
        public = false
        name = "back"
        endpoint = "back"
        cpu = 256
        memory = 512
        environment = [
          {
            name = "SERVICE_ENV_VAR"
            value = "yeeee"
          },
        ]
        deploy = {
          gitrepo = "kuttleio/back"
          dockerfilepath = "Dockerfile"
          method = "from_branch"
          branch = "master"
        }
      }
    }
    datastores = {
      # redis = {
      #   num_clusters = 1
      #   version = "7.1"
      #   node_type = "cache.t4g.micro"
      #   failover = false
      # }
      dynamodb = {
        main = {
          table_name                      = "main"
          billing_mode                    = "PROVISIONED"
          hash_key                        = "environment_id"
          read_capacity                   = 5
          write_capacity                  = 5
          server_side_encryption_enabled  = true
          deletion_protection_enabled     = true
          stream_enabled                  = true
          point_in_time_recovery_enabled  = true
          attributes = [
            {
              name = "environment_id"
              type = "S"
            },
          ]
        }
      }
  }
    envvars = [
      {
        name = "SHARED_ENV_VAR"
        value = "yooo"
      },
    ]
    secrets = []
    ipwhitelist = [
        "0.0.0.0/1",
        "128.0.0.0/1",
    ]
  }
}
