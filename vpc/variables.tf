variable "name" {
  type        = string
  description = "Env name"
  default     = "abc"
}

variable "cidr" {
  type        = string
  description = "VPC CIDR"
  default     = "10.10.0.0/16"
}

variable "region" {
  type        = string
  description = "Region name"
  default     = "eu-west-1"
}

variable "private_dns_name" {
  type    = string
  default = "abc.internal"
}


