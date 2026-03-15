module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  name = "plex"

  cidr           = local.vpc_cidr
  azs            = slice(data.aws_availability_zones.main.names, 0, 3)
  public_subnets = cidrsubnets(local.vpc_cidr, 4, 4, 4)

  enable_dns_hostnames = true
  enable_dns_support   = true
}
