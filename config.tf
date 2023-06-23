terraform {
  required_version = ">= 1.0"
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    logdna = {
      source = "logdna/logdna"
      version = "~> 1.0"
    }
    github = {
      source = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider aws {
  region = var.clp_region
  assume_role {
    role_arn     = var.provider_role_arn
    session_name = var.aws_provider_session_name
  }
}

provider logdna {
  servicekey = var.logdna_service_key
}

provider github {
  token = var.github_token
  owner = var.guthub_owner
}
