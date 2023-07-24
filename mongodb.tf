locals {
  region_name_bits  = split("-", var.clp_region)
  short_region_name = "${local.region_name_bits[0]}${substr(local.region_name_bits[1], 0, 1)}${substr(local.region_name_bits[2], 0, 1)}"
  short_region_name = "us-west-2"
  mongodb_region    = "${upper(local.region_name_bits[0])}_${upper(local.region_name_bits[1])}_${upper(local.region_name_bits[2])}" # us-west-2 --> US_WEST_2
  mongodb_region = "US_WEST_2"
  name_prefix    = "${local.short_region_name}-${var.clp_account}"
  standard_tags = merge(var.global_tags, var.env_tags, tomap({
    Name    = "MongoDB Atlas"
    Service = "MongoDB Atlas"
  }))
  # connection_bits = {
  #   for k, v in mongodbatlas_cluster.clusters.connection_strings[0].standard_srv : k => v
  # }
}


locals {
  mongodb_atlas = {
    "dev1" = {
      "project_name" = "dev1"
      "cluster1" = {
        "cluster_type"                = "REPLICASET"
        "provider_name"               = "TENANT"
        "backing_provider_name"       = "AWS"
        "provider_region_name"        = "EU_WEST_1"
        "provider_instance_size_name" = "M0"
        "replication_specs"           = {}
      }
      "users" = ["admin1", "admin2"]
    }
    "dev2" = {
      "project_name" = "dev2"
    }
    "test" = {
      "project_name" = "test"
    }
  }
  default_mongodb_settings = {
    "cluster_type"                 = "REPLICASET"
    "provider_name"                = "TENANT"
    "backing_provider_name"        = "AWS"
    "provider_region_name"         = "EU_WEST_1"
    "provider_instance_size_name"  = "M0"
    "mongo_db_major_version"       = "4.4"
    "auto_scaling_disk_gb_enabled" = false
    "replication_specs" = {
      "num_shards"      = 1
      "region_name"     = local.mongodb_region
      "electable_nodes" = 3
      "priority"        = 7
      "read_only_nodes" = 0
    }
  }
  mongodb_clusters = { for item in flatten([
    for project_name, project in local.mongodb_atlas : [
      for cluster_name, cluster in project : {
        project_name                 = project_name
        cluster_name                 = cluster_name
        cluster_type                 = coalesce(try(cluster.cluster_type, local.default_mongodb_settings.cluster_type), local.default_mongodb_settings.cluster_type)
        provider_name                = coalesce(try(cluster.provider_name, local.default_mongodb_settings.provider_name), local.default_mongodb_settings.provider_name)
        backing_provider_name        = coalesce(try(cluster.backing_provider_name, local.default_mongodb_settings.backing_provider_name), local.default_mongodb_settings.backing_provider_name)
        provider_region_name         = coalesce(try(cluster.provider_region_name, local.default_mongodb_settings.provider_region_name), local.default_mongodb_settings.provider_region_name)
        provider_instance_size_name  = coalesce(try(cluster.provider_instance_size_name, local.default_mongodb_settings.provider_instance_size_name), local.default_mongodb_settings.provider_instance_size_name)
        mongo_db_major_version       = coalesce(try(cluster.mongo_db_major_version, local.default_mongodb_settings.mongo_db_major_version), local.default_mongodb_settings.mongo_db_major_version)
        auto_scaling_disk_gb_enabled = coalesce(try(cluster.auto_scaling_disk_gb_enabled, local.default_mongodb_settings.auto_scaling_disk_gb_enabled), local.default_mongodb_settings.auto_scaling_disk_gb_enabled)
        replication_specs            = coalesce(try(contains(keys(cluster), "replication_specs") ? merge(cluster.replication_specs, local.default_mongodb_settings.replication_specs) : {}, {}), {})
      } if cluster_name != "project_name" && cluster_name != "users"
    ]
  ]) : "${item.project_name}_${item.cluster_name}" => item }

  mongodb_users = { for item in flatten([
    for project_name, project in local.mongodb_atlas : [
      for user in project.users : {
        project_name = project_name
        username     = user
      }
    ] if length(try(project.users, [])) > 0
  ]) : "${item.project_name}_${item.username}" => item }
}

resource "mongodbatlas_project" "projects" {
  for_each = local.mongodb_atlas
  name     = "${local.name_prefix}-${var.clp_wenv}-${each.value.project_name}"
  org_id   = var.mongodb_atlas_org_id
}

resource "mongodbatlas_cluster" "clusters" {
  for_each                     = local.mongodb_clusters
  project_id                   = mongodbatlas_project.projects[each.value.project_name].id
  name                         = "${local.name_prefix}-${var.clp_wenv}-${each.value.project_name}-${each.value.cluster_name}"
  auto_scaling_disk_gb_enabled = each.value.auto_scaling_disk_gb_enabled
  mongo_db_major_version       = each.value.mongo_db_major_version
  cluster_type                 = each.value.cluster_type
  provider_name                = each.value.provider_name
  backing_provider_name        = each.value.backing_provider_name
  provider_region_name         = each.value.provider_region_name
  provider_instance_size_name  = each.value.provider_instance_size_name

  dynamic "replication_specs" {
    for_each = [each.value.replication_specs]
    content {
      num_shards = replication_specs.value.num_shards
      regions_config {
        region_name     = replication_specs.value.region_name
        electable_nodes = replication_specs.value.electable_nodes
        priority        = replication_specs.value.priority
        read_only_nodes = replication_specs.value.read_only_nodes
      }
    }
  }
}

# ---------------------------------------------------
# Whitelist NAT IPs
# ---------------------------------------------------
resource "mongodbatlas_project_ip_access_list" "vpc_nat_ips" {
  for_each   = local.mongodb_atlas
  project_id = mongodbatlas_project.projects[each.key].id
  cidr_block = "${data.terraform_remote_state.vpc.outputs.nat_public_ips[0]}/32"
  comment    = "NAT Gateway IP from AWS VPC"
}

locals {
  mongodb_project_vpn_ip = merge([
    for project_name in keys(local.mongodb_atlas) : {
      for cidr in data.terraform_remote_state.ip_list.outputs.ip_list : "${project_name}|${cidr}" => cidr
    }
  ]...)
}

resource "mongodbatlas_project_ip_access_list" "vpn_ip_list" {
  for_each   = local.mongodb_project_vpn_ip
  project_id = mongodbatlas_project.projects[split("|", each.key)[0]].id
  cidr_block = each.value
  comment    = "VPN IP"
}

# ---------------------------------------------------
# User
# DATABASE USER  [Configure Database Users](https://docs.atlas.mongodb.com/security-add-mongodb-users/)
# ---------------------------------------------------
resource "mongodbatlas_database_user" "users" {
  for_each   = local.mongodb_users
  username   = "${local.name_prefix}-${var.clp_wenv}-${each.value.username}"
  password   = random_password.user_passwords[each.key].result
  project_id = mongodbatlas_project.projects[each.value.project_name].id
  auth_database_name = var.auth_database_name
  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }

  roles {
    role_name       = "readWrite"
    database_name   = "${local.name_prefix}-${var.clp_wenv}"
    collection_name = "${local.name_prefix}-${var.clp_wenv}"
  }
}

resource "random_password" "user_passwords" {
  for_each = local.mongodb_users
  length   = 24
  special  = false
}
