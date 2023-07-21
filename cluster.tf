# ---------------------------------------------------
#    ECS Fargate cluster
# ---------------------------------------------------
module "ecs_fargate" {
  source       = "terraform-aws-modules/ecs/aws"
  version      = "4.1.3"
  cluster_name = "${local.name_prefix}-${var.clp_zenv}"
  tags         = var.standard_tags

  cluster_settings = {
    name  = "containerInsights"
    value = "enabled"
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 0
        base   = 0
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        base   = 10
        weight = 100
      }
    }
  }
}

# ---------------------------------------------------
#    ECR Repo for automated deployment
# ---------------------------------------------------
resource "aws_ecr_repository" "main" {
  name                 = "${local.name_prefix}-${var.clp_zenv}"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "main" {
  repository = aws_ecr_repository.main.name
  policy     = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire untagged images older than 7 days",
      "selection": {
        "tagStatus": "untagged",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 7
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# ---------------------------------------------------
#    Force New Deployment
# ---------------------------------------------------
module "force_new_deployment" {
  source        = "github.com/kuttleio/aws_ecs_fargate_force_new_deployment//?ref=2.0.0"
  ecs_cluster   = module.ecs_fargate.cluster_arn
  name_prefix   = "${local.name_prefix}-${var.clp_zenv}"
  standard_tags = var.standard_tags
  account       = var.clp_account
}

# ---------------------------------------------------
#    Cluster - Outputs
# ---------------------------------------------------
output "cluster_id" {
  description = "ECS Fargate Cluster ID"
  value       = module.ecs_fargate.cluster_id
}

output "cluster_arn" {
  description = "ECS Fargate Cluster ARN"
  value       = module.ecs_fargate.cluster_arn
}

output "cluster_name" {
  description = "ECS Fargate Cluster Name"
  value       = module.ecs_fargate.cluster_name
}

output "ecr_repo_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.main.repository_url
}
