output "plex_url" {
  value       = "http://${aws_eip.plex.public_ip}:32400/web"
  description = "Plex server URL"
}
