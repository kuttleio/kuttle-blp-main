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
      value = data.terraform_remote_state.s3_tf_artefacts.outputs.id
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
  vpc         = data.terraform_remote_state.vpc.outputs.vpc_id
}

# ---------------------------------------------------
#    Services
# ---------------------------------------------------
module frontend {
  source                  = "github.com/kuttleio/aws_ecs_fargate_app"
  public                  = true
  service_name            = "frontend"
  service_image           = "${aws_ecr_repository.main.repository_url}:frontend"
  name_prefix             = local.name_prefix
  standard_tags           = var.standard_tags
  cluster_name            = module.ecs_fargate.cluster_name
  zenv                    = var.clp_zenv
  desired_count           = 2
  vpc_id                  = data.terraform_remote_state.vpc.outputs.vpc_id
  security_groups         = [data.terraform_remote_state.sg.outputs.clp_backend_sg, data.terraform_remote_state.sg.outputs.clp_bastion_sg, aws_security_group.main.id]
  subnets                 = data.terraform_remote_state.vpc.outputs.private_subnets
  ecr_account_id          = var.account_id
  ecr_region              = var.ecr_region
  aws_lb_arn              = aws_lb.frontend.arn
  aws_lb_certificate_arn  = data.aws_acm_certificate.main.arn
  logs_destination_arn    = module.lambda.lambda_function_arn
  domain_name             = var.domain_name
  task_role_arn           = aws_iam_role.main.arn
  secrets                 = setunion(data.terraform_remote_state.regional_secrets.outputs.regional_secrets)
  environment             = setunion(data.terraform_remote_state.regional_secrets.outputs.regional_env_vars, local.added_env)
}

module backend {
  source                  = "github.com/kuttleio/aws_ecs_fargate_app"
  public                  = true
  service_name            = "backend"
  service_image           = "${aws_ecr_repository.main.repository_url}:backend"
  name_prefix             = local.name_prefix
  standard_tags           = var.standard_tags
  cluster_name            = module.ecs_fargate.cluster_name
  zenv                    = var.clp_zenv
  desired_count           = 2
  vpc_id                  = data.terraform_remote_state.vpc.outputs.vpc_id
  security_groups         = [data.terraform_remote_state.sg.outputs.clp_backend_sg, data.terraform_remote_state.sg.outputs.clp_bastion_sg, aws_security_group.main.id]
  subnets                 = data.terraform_remote_state.vpc.outputs.private_subnets
  ecr_account_id          = var.account_id
  ecr_region              = var.ecr_region
  aws_lb_arn              = aws_lb.backend.arn
  aws_lb_certificate_arn  = data.aws_acm_certificate.main.arn
  logs_destination_arn    = module.lambda.lambda_function_arn
  domain_name             = var.domain_name
  task_role_arn           = aws_iam_role.main.arn
  secrets                 = setunion(data.terraform_remote_state.regional_secrets.outputs.regional_secrets)
  environment             = setunion(data.terraform_remote_state.regional_secrets.outputs.regional_env_vars, local.added_env, [
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
  source                  = "github.com/kuttleio/aws_ecs_fargate_app"
  public                  = false
  service_name            = "runner"
  service_image           = "${aws_ecr_repository.main.repository_url}:runner"
  name_prefix             = local.name_prefix
  standard_tags           = var.standard_tags
  cluster_name            = module.ecs_fargate.cluster_name
  zenv                    = var.clp_zenv
  vpc_id                  = data.terraform_remote_state.vpc.outputs.vpc_id
  security_groups         = [data.terraform_remote_state.sg.outputs.clp_backend_sg, data.terraform_remote_state.sg.outputs.clp_bastion_sg, aws_security_group.main.id]
  subnets                 = data.terraform_remote_state.vpc.outputs.private_subnets
  ecr_account_id          = var.account_id
  ecr_region              = var.ecr_region
  logs_destination_arn    = module.lambda.lambda_function_arn
  service_discovery_id    = aws_service_discovery_private_dns_namespace.main.id
  domain_name             = var.domain_name
  task_role_arn           = aws_iam_role.main.arn
  secrets                 = setunion(data.terraform_remote_state.regional_secrets.outputs.regional_secrets)
  environment             = setunion(data.terraform_remote_state.regional_secrets.outputs.regional_env_vars, local.added_env)
}
