terraform {
  required_version = ">= 1.0"
  required_providers {
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

provider logdna {
  servicekey = data.aws_ssm_parameter.logdna_service_key.value
}

provider github {
  token = data.aws_ssm_parameter.github_token.value
  owner = "kuttleio"
}
