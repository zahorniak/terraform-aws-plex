module "plex" {
  source           = "../../"
  plex_libraries   = var.plex_libraries
  plex_claim_token = var.plex_claim_token
  force_destroy    = true
}
