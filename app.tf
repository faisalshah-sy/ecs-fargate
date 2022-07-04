

variable "app_version" {}

variable "alb_name" {
  default = "abc"
}

variable "service_name" {
  default = "abc"
}

variable "service_port" {
  default = 8080
}

variable "target_group_name" {
  default = "abc"
}

variable "repo_name" {
  default = "abc-sevice"
}


module "app" {
  source            = "./terraform_module/ecs-app"
  alb_name          = var.alb_name
  repo_name         = var.repo_name
  service_name      = var.service_name
  service_port      = var.service_port
  target_group_name = var.target_group_name
  app_version       = var.app_version
  private_subnets   = ["","",""]
  domain            = ""
  public_subnets    = ["","",""]
  route53_zone      = ""
  vpc_cidr          = ""
  vpc_id            = ""
}
