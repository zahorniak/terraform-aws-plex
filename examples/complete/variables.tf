variable "plex_libraries" {
  type        = list(string)
  description = "List of Plex libraries"
}

variable "plex_claim_token" {
  type        = string
  description = "Token to claim your plex media server.  You can get this by going to https://www.plex.tv/claim."
}
