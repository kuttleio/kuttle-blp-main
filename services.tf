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
    {
      name  = "GITHUB_REPOSITORY"
      value = "your-repo/your-repo-name"
    },
    {
      name  = "GITHUB_ACCESS_TOKEN"
      value = "your-access-token"
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
module frontend {
  source                  = "github.com/kuttleio/aws_ecs_fargate_app?ref=1.1.1"
  public                  = true
  service_name            = "frontend"
  service_image           = "${aws_ecr_repository.main.repository_url}:frontend"
  name_prefix             = local.name_prefix
  standard_tags           = var.standard_tags
  cluster_name            = module.ecs_fargate.cluster_name
  zenv                    = var.clp_zenv
  container_cpu           = var.frontend_container_cpu
  container_memory        = var.frontend_container_memory
  vpc_id                  = var.vpc_id
  security_groups         = var.security_groups
  subnets                 = var.private_subnets
  ecr_account_id          = var.account_id
  ecr_region              = var.ecr_region
  aws_lb_arn              = aws_lb.frontend.arn
  aws_lb_certificate_arn  = data.aws_acm_certificate.main.arn
  logs_destination_arn    = module.lambda.lambda_function_arn
  domain_name             = var.domain_name
  task_role_arn           = aws_iam_role.main.arn
  secrets                 = setunion(var.secrets)
  environment             = setunion(var.envvars, local.added_env)
}

module backend {
  source                  = "github.com/kuttleio/aws_ecs_fargate_app?ref=1.1.1"
  public                  = true
  service_name            = "backend"
  service_image           = "${aws_ecr_repository.main.repository_url}:backend"
  name_prefix             = local.name_prefix
  standard_tags           = var.standard_tags
  cluster_name            = module.ecs_fargate.cluster_name
  zenv                    = var.clp_zenv
  container_cpu           = var.backend_container_cpu
  container_memory        = var.backend_container_memory
  vpc_id                  = var.vpc_id
  security_groups         = var.security_groups
  subnets                 = var.private_subnets
  ecr_account_id          = var.account_id
  ecr_region              = var.ecr_region
  aws_lb_arn              = aws_lb.backend.arn
  aws_lb_certificate_arn  = data.aws_acm_certificate.main.arn
  logs_destination_arn    = module.lambda.lambda_function_arn
  domain_name             = var.domain_name
  task_role_arn           = aws_iam_role.main.arn
  secrets                 = setunion(var.secrets)
  environment             = setunion(var.envvars, local.added_env, [
    {
      name  = "UPDATE_STATUSES_CRON"
      value = "*/10 * * * *"
    },
    {
      name  = "IS_WORKER"
      value = "1"
    },
  ])
}

module runner {
  source                  = "github.com/kuttleio/aws_ecs_fargate_app?ref=1.1.1"
  public                  = false
  service_name            = "runner"
  service_image           = "${aws_ecr_repository.main.repository_url}:runner"
  name_prefix             = local.name_prefix
  standard_tags           = var.standard_tags
  cluster_name            = module.ecs_fargate.cluster_name
  zenv                    = var.clp_zenv
  container_cpu           = var.runner_container_cpu
  container_memory        = var.runner_container_memory
  vpc_id                  = var.vpc_id
  security_groups         = var.security_groups
  subnets                 = var.private_subnets
  ecr_account_id          = var.account_id
  ecr_region              = var.ecr_region
  logs_destination_arn    = module.lambda.lambda_function_arn
  service_discovery_id    = aws_service_discovery_private_dns_namespace.main.id
  domain_name             = var.domain_name
  task_role_arn           = aws_iam_role.main.arn
  secrets                 = setunion(var.secrets)
  environment             = setunion(var.envvars, local.added_env)
}
