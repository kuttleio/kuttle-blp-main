terraform {
  required_version = ">= 1.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    logdna = {
      source  = "logdna/logdna"
      version = "~> 1.0"
    }
  }
}

provider "github" {
  token = data.aws_ssm_parameter.github_token.value
  owner = "kuttleio"
}

provider "logdna" {
  servicekey = data.aws_ssm_parameter.logdna_service_key.value
}
