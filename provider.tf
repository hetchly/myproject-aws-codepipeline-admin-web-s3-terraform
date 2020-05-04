provider "aws" {
  version = "~> 2.0"
  region  = var.aws_region
}

terraform {
  required_version = "~> 0.12.0"

  required_providers {
    aws   = "~> 2.0"
  }
}