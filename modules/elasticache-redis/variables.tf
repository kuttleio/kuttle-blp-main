variable "enabled" {
  description = "Whether to create the resource"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Whether to enable encryption in transit"
  type        = bool
  default     = false
}

variable "auth_token" {
  description = "The password used to access a password protected server"
  type        = string
  default     = null
}

variable "replication_group_id" {
  description = "The replication group identifier. This parameter is stored as a lowercase string."
  type        = string
}

variable "replication_group_description" {
  description = "The replication group description."
  type        = string
  default     = null
}

variable "node_type" {
  description = "The compute and memory capacity of the nodes in the node group"
  type        = string
  default     = "cache.t2.micro"
}

variable "cluster_mode_enabled" {
  description = "Whether to enable clustering"
  type        = bool
  default     = false
}

variable "num_cache_clusters" {
  description = "The number of clusters this replication group will have"
  type        = number
  default     = 1
}

variable "port" {
  description = "The port number on which each of the cache nodes will accept connections"
  type        = number
  default     = 6379
}

variable "automatic_failover_enabled" {
  description = "Specifies whether a read-only replica is automatically promoted to read/write primary if the existing primary fails"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Specifies whether to enable Multi-AZ Support for the replication group"
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "A list of VPC Security Groups associated with the cache cluster"
  type        = list(string)
  default     = []
}

variable "maintenance_window" {
  description = "Specifies the weekly time range during which maintenance on the cache cluster is performed"
  type        = string
  default     = "sun:05:00-sun:09:00"
}

variable "engine" {
  description = "The name of the cache engine to be used for the cache clusters in this replication group"
  type        = string
  default     = "redis"
}

variable "engine_version" {
  description = "The version number of the cache engine to be used for the cache clusters in this replication group"
  type        = string
  default     = "5.0.6"
}

variable "at_rest_encryption_enabled" {
  description = "Whether to enable encryption at rest"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "The ARN of the KMS key to be used for encryption at rest"
  type        = string
  default     = null
}

variable "snapshot_window" {
  description = "The daily time range (in UTC) during which ElastiCache will begin taking a daily snapshot of your node group (shard)"
  type        = string
  default     = "05:00-09:00"
}

variable "snapshot_retention_limit" {
  description = "The number of days for which ElastiCache will retain automatic cache cluster snapshots before deleting them"
  type        = number
  default     = 0
}

variable "apply_immediately" {
  description = "Specifies whether any modifications are applied immediately, or during the next maintenance window"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Specifies whether minor engine upgrades will be applied automatically to the underlying cache cluster instances during the maintenance window"
  type        = bool
  default     = true
}

variable "cluster_mode_num_node_groups" {
  description = "The number of node groups (shards) for this Redis replication group"
  type        = number
  default     = 1
}

variable "cluster_mode_replicas_per_node_group" {
  description = "An optional parameter that specifies the number of replica nodes in each node group (shard)"
  type        = number
  default     = 0
}

variable "subnet_ids" {
  description = "A list of VPC Subnet IDs for the cache subnet group"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}