data "aws_availability_zones" "main" {
  state = "available"
}

data "aws_ami" "plex" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["plex-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # x86_64 or arm64
  }
}
