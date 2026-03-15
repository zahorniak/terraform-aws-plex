module "plex" {
  source           = "../../"
  plex_libraries   = ["movies", "tv"]
  plex_claim_token = "claim-KL7s1QvWn_5xdhx4uyJv"
  force_destroy    = true
}
