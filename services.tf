# ---------------------------------------------------
#    Additional Env Variables
# ---------------------------------------------------
locals {
  added_env = [
    {
      name  = "REACT_APP_BACKEND_ENDPOINT"
      value = "https://${aws_route53_record.backend.fqdn}/api/v1"
    },
    {
      name  = "BACKEND_PATH"
      value = "https://${aws_route53_record.backend.fqdn}"
    },
    {
      name  = "FRONTEND_PATH"
      value = "https://${aws_route53_record.frontend.fqdn}"
    },
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
resource aws_service_discovery_private_dns_namespace main {
  name        = "${local.name_prefix}-${var.clp_zenv}-ns"
  description = "${local.name_prefix}-${var.clp_zenv} Private Namespace"
  vpc         = var.vpc_id
}

# ---------------------------------------------------
#    Services
# ---------------------------------------------------
module fargate_service {
  source        = "github.com/kuttleio/aws_ecs_fargate_app?ref=feature-add-mulitple-service"
  
  # Pass the services list directly to for_each
  for_each      = { for service in var.services : service.name => service }

  # Service-specific parameters
  service_name      = each.key
  service_image     = "${aws_ecr_repository.main.repository_url}:${each.value.name}"
  name_prefix       = local.name_prefix
  standard_tags     = var.standard_tags
  cluster_name      = module.ecs_fargate.cluster_name
  zenv              = var.clp_zenv
  container_cpu     = each.value.cpu
  container_memory  = each.value.memory
  vpc_id            = var.vpc_id
  security_groups   = var.security_groups
  subnets           = var.private_subnets
  ecr_account_id    = var.account_id
  ecr_region        = var.ecr_region
  logs_destination_arn = module.logdna.lambda_function_arn
  domain_name       = var.domain_name
  task_role_arn     = aws_iam_role.main.arn
  secrets           = setunion(var.secrets, each.value.secrets)
  environment       = setunion(var.envvars, each.value.envvars)
  
  # Service deployment configuration
  deploy_method     = each.value.deploy.method
  git_repo          = each.value.deploy.gitrepo
  dockerfile        = each.value.deploy.dockerfile
  branch            = each.value.deploy.branch
}


