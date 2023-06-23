data github_repository frontend {
  full_name = "kuttleio/frontend"
}

data github_repository backend {
  full_name = "kuttleio/backend"
}

data github_repository runner {
  full_name = "kuttleio/runner"
}

resource github_repository_file frontend {
  repository          = data.github_repository.frontend.name
  branch              = "master"
  file                = ".github/workflows/${local.name_prefix}-${var.clp_zenv}.yaml"
  commit_message      = "Add CICD: delivery from /master to ${var.clp_zenv}"
  commit_author       = "kuttle-bot"
  commit_email        = "kbot@ktl.ai"
  overwrite_on_create = true

  content = templatefile("${path.module}/cicd.tpl.yaml", {
    service_name  = "frontend"
    zenv          = var.clp_zenv
    region        = var.clp_region
    deploy_branch = "master"
    cluster_name  = module.ecs_fargate.cluster_name
  })
}

resource github_repository_file backend {
  repository          = data.github_repository.backend.name
  branch              = "master"
  file                = ".github/workflows/${local.name_prefix}-${var.clp_zenv}.yaml"
  commit_message      = "Add CICD: delivery from /master to ${var.clp_zenv}"
  commit_author       = "kuttle-bot"
  commit_email        = "kbot@ktl.ai"
  overwrite_on_create = true

  content = templatefile("${path.module}/cicd.tpl.yaml", {
    service_name  = "backend"
    zenv          = title(var.clp_zenv)
    region        = var.clp_region
    deploy_branch = "master"
    cluster_name  = module.ecs_fargate.cluster_name
  })
}

resource github_repository_file runner {
  repository          = data.github_repository.runner.name
  branch              = "master"
  file                = ".github/workflows/${local.name_prefix}-${var.clp_zenv}.yaml"
  commit_message      = "Add CICD: delivery from /master to ${var.clp_zenv}"
  commit_author       = "kuttle-bot"
  commit_email        = "kbot@ktl.ai"
  overwrite_on_create = true

  content = templatefile("${path.module}/cicd.tpl.yaml", {
    service_name  = "runner"
    zenv          = title(var.clp_zenv)
    region        = var.clp_region
    deploy_branch = "master"
    cluster_name  = module.ecs_fargate.cluster_name
  })
}
