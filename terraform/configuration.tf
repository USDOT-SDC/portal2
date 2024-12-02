terraform {
  required_version = "~> 1.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.78"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.6"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
  }
  backend "s3" {
    # Variables can not be used here
    region = "us-east-1"
    key    = "portal2/terraform/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = local.default_tags
  }
}
