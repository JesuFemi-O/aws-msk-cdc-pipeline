terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "placeholder"
    key = "placeholder"
    region = "us-east-2"
  }
}

# TODO: find a cleaner way to use a local backend or move to s3 backend
provider "aws" {
  shared_config_files      = ["/Users/emmanuelogunwede/.aws/config"]
  shared_credentials_files = ["/Users/emmanuelogunwede/.aws/credentials"]
  profile                  = "vscode"
  region = "us-east-2"
}