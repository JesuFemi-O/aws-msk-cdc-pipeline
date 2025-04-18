variable "vpc_cidr" {
  type        = string
  description = "Public Subnet CIDR values"
  default     = "10.0.0.0/16"
}

variable "cidr_public_subnet" {
  type        = string
  description = "Public Subnet CIDR values"
  default     = "10.0.1.0/24"
}


variable "cidr_public_internet" {
  type        = string
  description = "Public Subnet CIDR values"
  default     = "0.0.0.0/0"
}

variable "public_subnet_availability_zone" {
 type        = string
 description = "Availability Zones"
 default     = "us-east-2a"
}

variable "cidr_private_subnet" {
  type        = list(string)
  description = "Private Subnet CIDR values"
  default     = ["10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "us_availability_zone" {
 type        = list(string)
 description = "Availability Zones"
 default     = ["us-east-2a", "us-east-2b", "us-east-2c"]
}


variable "rds_master_user" {
  type        = string
  description = "RDS Instance master Username"
  sensitive = true
  default = "cdcdemo"
}


variable "tf_state_bucket_name" {
  type        = string
  description = "TF Backend bucket"
  default = "terraform-state-msk-cdc"
}

variable "tf_state_key" {
  type        = string
  description = "TF Backend Key Path in S3 Bucket"
  default = "msk-cdc/state/terraform.tfstate"
}