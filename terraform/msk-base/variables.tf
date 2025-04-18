variable "cidr_public_internet" {
  type        = string
  description = "Public Subnet CIDR values"
  default     = "0.0.0.0/0"
}

variable "cidr_public_allow_list" {
  type        = list(string)
  description = "Public Subnet CIDR values"
  # public internet is a work around until I figure out connectivity issue for msk->ec2 traffic
  default     = ["0.0.0.0/0"]
}