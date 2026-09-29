terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80"
    }
  }

  # Remote state: create the bucket once, then uncomment and run `terraform init -migrate-state`.
  # backend "s3" {
  #   bucket       = "<your-tfstate-bucket>"
  #   key          = "ml-platform/dev/terraform.tfstate"
  #   region       = "eu-west-3"
  #   use_lockfile = true
  #   encrypt      = true
  # }
}

provider "aws" {
  region = var.region
}
