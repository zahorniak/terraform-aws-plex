module "plex_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 9.2"

  name                            = "plex"
  use_name_prefix                 = true
  ignore_desired_capacity_changes = true
  min_size                        = 1
  max_size                        = 1
  desired_capacity                = 1
  wait_for_capacity_timeout       = 0
  health_check_type               = "EC2"
  vpc_zone_identifier             = module.vpc.public_subnets
  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      instance_warmup        = 30
      min_healthy_percentage = 0
    }
  }

  launch_template_name   = "plex"
  update_default_version = true

  image_id      = data.aws_ami.plex.id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh",
    {
      STORAGE_BUCKET     = module.s3_plex_storage.s3_bucket_id
      CONFIG_BUCKET      = module.s3_plex_db.s3_bucket_id
      LIBRARIES          = var.plex_libraries
      AWS_REGION         = var.aws_region
      CLAIM_TOKEN_SHA256 = sha256(var.plex_claim_token)
    }
  ))

  ebs_optimized     = true
  enable_monitoring = false

  block_device_mappings = [
    {
      # Root volume
      device_name = "/dev/xvda"
      no_device   = 0
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = var.instance_storage_size
        volume_type           = "gp3"
      }
    }
  ]

  create_iam_instance_profile = true
  iam_role_name               = "plex"
  iam_role_path               = "/ec2/"

  iam_role_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    S3Access                     = aws_iam_policy.plex_server.arn
  }

  instance_market_options = {
    market_type = "spot"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  network_interfaces = [
    {
      associate_public_ip_address = true
      delete_on_termination       = true
      description                 = "eth0"
      device_index                = 0
      security_groups             = [aws_security_group.plex_admin.id]
    }
  ]
}
