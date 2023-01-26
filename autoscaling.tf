module "plex_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.5"

  name                                 = "plex"
  use_name_prefix                      = true
  ignore_desired_capacity_changes      = true
  min_size                             = 1
  max_size                             = 1
  desired_capacity                     = 1
  wait_for_capacity_timeout            = 0
  health_check_type                    = "EC2"
  vpc_zone_identifier                  = module.vpc.public_subnets
  instance_initiated_shutdown_behavior = "terminate"
  protect_from_scale_in                = false

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay       = 600
      checkpoint_percentages = [35, 70, 100]
      instance_warmup        = 30
      min_healthy_percentage = 50
    }
  }

  launch_template_name   = "plex"
  update_default_version = true

  image_id      = data.aws_ami.plex.id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/templates/userdata.sh",
    {
      BUCKETS             = local.buckets,
      BUCKET_FSTAB_STRING = local.bucket_fstab_string
      EIP_ID              = aws_eip.plex.id
      CONFIG_BUCKET       = module.s3_plex_db.s3_bucket_id
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
        iops                  = 3000
        throughput            = 125
      }
    }
  ]

  schedules = {
    night = {
      min_size         = 0
      max_size         = 0
      desired_capacity = 0
      recurrence       = "0 0 * * *" # Mon-Fri in the evening
      time_zone        = "Europe/Kyiv"
    }

    morning = {
      min_size         = 1
      max_size         = 1
      desired_capacity = 1
      recurrence       = "0 9 * * *" # Mon-Fri in the morning
      time_zone        = "Europe/Kyiv"
    }
  }

  create_iam_instance_profile = true
  iam_role_name               = "plex"
  iam_role_path               = "/ec2/"

  iam_role_policies = {
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role",
    S3Access                            = aws_iam_policy.plex_server.arn
  }

  capacity_reservation_specification = {
    capacity_reservation_preference = "open"
  }

  instance_market_options = {
    market_type = "spot"
  }

  maintenance_options = {
    auto_recovery = "default"
  }

  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 32
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
