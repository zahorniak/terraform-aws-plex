provider "aws" {
  region                      = var.aws_region
  skip_credentials_validation = true

  default_tags {
    tags = {
      Terraform   = "true"
      Application = "plex"
    }
  }
}
