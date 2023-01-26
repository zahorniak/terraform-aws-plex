data "aws_iam_policy_document" "plex_ec2" {
  statement {
    actions = [
      "s3:*"
    ]

    resources = flatten([
      for bucket in module.s3_plex_storage : [
        bucket.s3_bucket_arn,
        "${bucket.s3_bucket_arn}/*",
      ]
    ])
  }

  statement {
    actions = [
      "s3:*"
    ]

    resources = [
      module.s3_plex_db.s3_bucket_arn,
      "${module.s3_plex_db.s3_bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "ssm:DescribeParameters",
      "ec2:AssociateAddress"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "ssm:GetParameter"
    ]
    resources = [
      aws_ssm_parameter.plex_claim_token.arn
    ]
  }
}

resource "aws_iam_policy" "plex_server" {
  name_prefix = "plex-ec2-"
  description = "Policy for Plex EC2 instance"
  policy      = data.aws_iam_policy_document.plex_ec2.json
}
