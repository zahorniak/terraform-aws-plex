locals {
  vpc_cidr_blocks = cidrsubnets("10.0.0.0/16", 2, 2, 2, 2)
}

locals {
  buckets = flatten([
    for bucket in module.s3_plex_storage : [
      bucket.s3_bucket_id
    ]
  ])

  bucket_fstab_list = flatten([
    for bucket in module.s3_plex_storage : [
      "plex\\x2ddata-${replace(bucket.s3_bucket_id, "-", "\\x2d")}.mount"
    ]
  ])

  bucket_fstab_string = join(" ", local.bucket_fstab_list)
}