terraform {
  required_version = ">= 1.0"
  backend "s3" {}
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
  servicekey = var.logdna_service_key
}

provider github {
  token = var.github_token
  owner = var.guthub_owner
}
