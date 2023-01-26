variable "plex_libraries" {
  type        = list(string)
  description = "List of Plex libraries"
}

variable "instance_type" {
  type        = string
  default     = "t3.small"
  description = "Type of EC2 instance"
}

variable "instance_storage_size" {
  type        = number
  default     = 30
  description = "Size for EC2 EBS root volume"
}

variable "plex_claim_token" {
  type        = string
  description = "Token to claim your plex media server.  You can get this by going to https://www.plex.tv/claim."
}

variable "aws_region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS Region"
}
