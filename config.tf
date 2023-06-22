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
  servicekey = data.aws_ssm_parameter.logdna_service_key.value
}

provider github {
  token = data.aws_ssm_parameter.github_token.value
  owner = "kuttleio"
}
