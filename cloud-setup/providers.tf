// devops-providers.tf -- define the devops providers
//================================================== PROVIDERS
# Configure the AWS Provider
terraform {
  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.0.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "3.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.0.0"
    }
  }
}

# see provider resource in keys file