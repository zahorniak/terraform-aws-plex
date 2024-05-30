module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.8"

  name = "plex"

  cidr            = "10.0.0.0/16"
  azs             = slice(data.aws_availability_zones.main.names, 0, 3)
  private_subnets = cidrsubnets(local.vpc_cidr_blocks[1], 2, 2, 2)
  public_subnets  = cidrsubnets(local.vpc_cidr_blocks[2], 2, 2, 2)

  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = false
}
