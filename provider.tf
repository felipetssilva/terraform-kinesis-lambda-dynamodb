terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.87.0"
      region = "us-east-1"

    }
  }
  backend "s3" {
    bucket = "s3-backend-state"
    key    = "s3-backup"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"
}
