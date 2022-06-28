module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.78.0"

  name = var.name
  cidr = var.cidr

  azs = [
    "${var.region}a",
    "${var.region}b",
    "${var.region}c",
  ]

  # /24 subnets in numeric order
  public_subnets = [
    cidrsubnet(var.cidr, 4, 1),
    cidrsubnet(var.cidr, 4, 2),
    cidrsubnet(var.cidr, 4, 3),
  ]

  private_subnets = [
    cidrsubnet(var.cidr, 4, 4),
    cidrsubnet(var.cidr, 4, 5),
    cidrsubnet(var.cidr, 4, 6),
  ]

  database_subnets = [
    cidrsubnet(var.cidr, 4, 7),
    cidrsubnet(var.cidr, 4, 8),
    cidrsubnet(var.cidr, 4, 9),
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  enable_s3_endpoint       = true
  enable_dynamodb_endpoint = true

  map_public_ip_on_launch  = false
  enable_dns_hostnames     = true
  enable_dhcp_options      = true
  dhcp_options_domain_name = "abc.internal"

  tags = {
    profile = var.name
  }
}

