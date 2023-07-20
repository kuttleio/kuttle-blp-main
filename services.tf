# ---------------------------------------------------
#    Additional Env Variables
# ---------------------------------------------------
locals {
  added_env = [
    {
      name  = "QUEUE_URL"
      value = aws_sqs_queue.main.url
    },
    {
      name  = "QUEUE_URL_REVERSED"
      value = aws_sqs_queue.reversed.url
    },
    {
      name  = "S3_TERRAFORM_ARTEFACTS"
      value = var.s3_tf_artefacts
    },
  ]
}

# ---------------------------------------------------
#    Service Discovery Namespace
# ---------------------------------------------------
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "${local.name_prefix}-${var.clp_zenv}-ns"
  description = "${local.name_prefix}-${var.clp_zenv} Private Namespace"
  vpc         = var.vpc_id
}

# ---------------------------------------------------
#    Services
# ---------------------------------------------------
locals {
  default_common_settings = {
    public      = false
    environment = concat((var.envvars), local.added_env) # concat(tolist(var.envvars), local.added_env)
    secrets     = var.secrets
    tags        = var.standard_tags
  }

  services = {
    for service_name, service_config in var.services : service_name => merge(
      local.default_common_settings,
      {
        name                 = service_config.name
        cpu                  = service_config.cpu
        memory               = service_config.memory
        endpoint             = try(coalesce(service_config.endpoint, ""), "")
        command              = try(coalesce(service_config.command, null), null)
        deploy_gitrepo       = service_config.deploy.gitrepo
        deploy_dockefilepath = coalesce(service_config.deploy.dockerfilepath, "Dockerfile")
        deploy_branch        = coalesce(service_config.deploy.branch, "master")
        deploy_method        = try(coalesce(service_config.deploy.method, null), null)
        deploy_version       = try(coalesce(service_config.deploy.version, null), null)
        environment          = service_config.environment != null && length(service_config.environment) > 0 ? concat(local.default_common_settings.environment, service_config.environment) : local.default_common_settings.environment
        secrets              = service_config.secrets != null ? concat(local.default_common_settings.secrets, service_config.secrets) : local.default_common_settings.secrets
        standard_tags        = service_config.tags != null ? merge(local.default_common_settings.tags, service_config.tags) : local.default_common_settings.tags
      },
      service_config,
    )
  }
}

module "services" {
  for_each               = local.services
  source                 = "github.com/kuttleio/aws_ecs_fargate_app?ref=1.1.1"
  public                 = each.value.public
  service_name           = each.value.name
  service_image          = "${aws_ecr_repository.main.repository_url}:${each.value.name}"
  name_prefix            = local.name_prefix
  standard_tags          = each.value.tags
  cluster_name           = module.ecs_fargate.cluster_name
  zenv                   = var.clp_zenv
  container_cpu          = each.value.cpu
  container_memory       = each.value.memory
  vpc_id                 = var.vpc_id
  security_groups        = var.security_groups
  subnets                = var.private_subnets
  ecr_account_id         = var.account_id
  ecr_region             = var.ecr_region
  aws_lb_arn             = each.value.public ? aws_lb.loadbalancers[each.value.service_name].arn : ""
  aws_lb_certificate_arn = each.value.public ? data.aws_acm_certificate.main.arn : ""
  service_discovery_id   = each.value.public ? "" : aws_service_discovery_private_dns_namespace.main.id
  logs_destination_arn   = module.logdna.lambda_function_arn
  domain_name            = var.domain_name
  task_role_arn          = aws_iam_role.main.arn
  secrets                = each.value.secrets
  environment            = each.value.environment
  command                = each.value.command
}

