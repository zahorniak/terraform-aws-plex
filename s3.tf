##########
### S3 ###
##########

module "s3_plex_db" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.3"

  bucket_prefix = "plex-db-"
  acl           = "private"

  block_public_acls   = false
  block_public_policy = false

  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
    }
  ]

  lifecycle_rule = [
    {
      id      = "moveToIT"
      enabled = true
      transition = [
        {
          days          = 1
          storage_class = "INTELLIGENT_TIERING"
        }
      ]
      noncurrent_version_transition = [
        {
          noncurrent_days = 1
          storage_class   = "INTELLIGENT_TIERING"
        }
      ]
    },
    {
      id                                     = "removeOldVersions"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 1
      expiration = {
        days                         = 0
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration = [
        {
          newer_noncurrent_versions = 1
          noncurrent_days           = 7
        }
      ]
    }
  ]

  versioning = {
    enabled = false
  }
}

module "s3_plex_storage" {
  for_each = toset(var.plex_libraries)

  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.3"

  bucket_prefix = "${each.value}-"
  acl           = "private"

  block_public_acls   = false
  block_public_policy = false

  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["*"]
    }
  ]

  lifecycle_rule = [
    {
      id      = "moveToIT"
      enabled = true
      transition = [
        {
          days          = 1
          storage_class = "INTELLIGENT_TIERING"
        }
      ]
      noncurrent_version_transition = [
        {
          noncurrent_days = 1
          storage_class   = "INTELLIGENT_TIERING"
        }
      ]
    },
    {
      id                                     = "removeOldVersions"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 1
      expiration = {
        days                         = 0
        expired_object_delete_marker = true
      }
      noncurrent_version_expiration = [
        {
          newer_noncurrent_versions = 1
          noncurrent_days           = 7
        }
      ]
    }
  ]

  versioning = {
    enabled = false
  }
}
