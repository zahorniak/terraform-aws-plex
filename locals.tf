locals {
  vpc_cidr_blocks = cidrsubnets("10.0.0.0/16", 2, 2, 2, 2)

  s3_lifecycle_rules = [
    {
      id      = "moveToIT"
      enabled = true
      transition = [
        {
          days          = 0
          storage_class = "INTELLIGENT_TIERING"
        }
      ]
    },
    {
      id                                     = "abortIncompleteUploads"
      enabled                                = true
      abort_incomplete_multipart_upload_days = 1
    }
  ]
}
