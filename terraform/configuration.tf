terraform {
  required_version = ">= 1.14"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.31"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.7"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.6"
    }
    template = {
      source  = "hashicorp/template"
      version = "~> 2.2"
    }
    git = {
      source  = "metio/git"
      version = "~> 2025.12"
    }
    time = {
      source = "hashicorp/time"
      version = "~> 0.13"
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
