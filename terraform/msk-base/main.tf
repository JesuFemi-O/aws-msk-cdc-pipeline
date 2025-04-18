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


locals {
    vpc_name = "VPC: vpc-msk-cdc-example"
    rds_security_group_name = "msk-rds-security-group"
    public_subnet_name = "Subnet-Public : msk_cdc_public_subnet"
    first_private_subnet = "Subnet-Private : private-subnet-2"
    second_private_subnet = "Subnet-Private : private-subnet-4"
    third_private_subnet = "Subnet-Private : private-subnet-5"
    cloud_watch_group_name = "msk-custom-cdc-log-group"
    cloud_watch_log_retention_in_days = 7
    msk_config_name = "msk-custom-configuration"
    kafka_version = "3.6.0"
    msk_cluster_name = "cdc-poc-msk-custom-cluster"
    kafka_instance_type = "kafka.t3.small"
    ec2_ami = "ami-0942ecd5d85baa812"
    ec2_instance_type = "t3.xlarge"

}


# pull in the server property file
data "local_file" "server_properties" {
  filename = "${path.module}/msk_server.properties"
}


# use tag based strategy to import aws resources into stack
data "aws_vpc" "vpc_staging" {
  tags = {
    Name = local.vpc_name
  }

}

data "aws_subnet" "public_subnet_1" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_staging.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.public_subnet_name]
  }
}

data "aws_subnet" "private_subnet_2" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_staging.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.first_private_subnet]
  }
}

data "aws_subnet" "private_subnet_4" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_staging.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.second_private_subnet]
  }
}

data "aws_subnet" "private_subnet_5" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_staging.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.third_private_subnet]
  }
}

# import rds security group
data "aws_security_group" "rds_security_group" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_staging.id]
  }

  filter {
    name   = "tag:Name"
    values = [local.rds_security_group_name]
  }
}
