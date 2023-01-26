resource "aws_security_group" "plex_admin" {
  name_prefix = "plex-"
  description = "Allow Administration of the plex server."
  vpc_id      = module.vpc.vpc_id

  ingress {
    # Plex
    from_port   = 32400
    to_port     = 32400
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 65535
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
