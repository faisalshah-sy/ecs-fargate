variable "alb_name" {
  type = string
}

variable "target_group_name" {
  type = string
}

variable "ecs_service_sg_name" {
  type = string
  default = "internal"
}

variable "service_port" {}

variable "repo_name" {
  type = string
}

variable "service_name" {
  type = string
}

variable "app_version" {
  type = string
}

variable "private_subnets" {
  type = list
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "domain" {
  type = string
}

variable "public_subnets" {
  type = list
}

variable "route53_zone" {
  type = string
}