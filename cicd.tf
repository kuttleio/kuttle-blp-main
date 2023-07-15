data "github_repository" "repositories" {
  for_each  = var.services
  full_name = "kuttleio/${each.key}"
}

resource "github_repository_file" "respository_files" {
  for_each            = var.services
  repository          = data.github_repository.repositories[each.key].name
  branch              = "master"
  file                = ".github/workflows/${local.name_prefix}-${var.clp_zenv}.yaml"
  commit_message      = "Add CICD: delivery from /master to ${var.clp_zenv}"
  commit_author       = "kuttle-bot"
  commit_email        = "kbot@ktl.ai"
  overwrite_on_create = true

  content = templatefile("${path.module}/cicd.tpl.yaml", {
    service_name  = each.key
    zenv          = title(var.clp_zenv)
    region        = var.clp_region
    deploy_branch = "master"
    cluster_name  = module.ecs_fargate.cluster_name
  })
}
