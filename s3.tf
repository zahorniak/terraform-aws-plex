module "s3_plex_db" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.10"

  bucket_prefix  = "plex-db-"
  force_destroy  = var.force_destroy
  lifecycle_rule = local.s3_lifecycle_rules
}

module "s3_plex_storage" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.10"

  bucket_prefix  = "plex-storage-"
  force_destroy  = var.force_destroy
  lifecycle_rule = local.s3_lifecycle_rules
}
