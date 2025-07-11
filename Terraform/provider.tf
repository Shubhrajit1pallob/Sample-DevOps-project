terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "full-scale-app-automation-cicd"
    key = "aws/ec2-depoy/terraform.tfstate"
    region = var.region
  }
  required_version = "~> 1.0"
}

provider "aws" {
  region = var.region
}

