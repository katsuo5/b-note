terraform {
  required_version = ">=1.5.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.40"
    }
  }
}

provider "aws" {
  region     = var.provider_region
  access_key = var.secret_access_key
  secret_key = var.secret_key
}
