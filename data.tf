data "aws_availability_zones" "main" {
  state = "available"
}

data "aws_ami" "plex" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name = "name"
    #     values = ["${var.packer_ami_prefix}-*"]
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}
