terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34"
    }
  }

  backend "s3" {
  }
}

provider "aws" {
  region  = var.aws-region
  default_tags {
    tags = {
      environment = var.environment
      created_by  = "terraform"
      service = var.service-name
    }
  }
}
