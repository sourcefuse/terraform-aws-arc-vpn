output "client_vpn_arn" {
  value       = module.vpn.client_vpn_arn
  description = "The Keycloak-integrated Client VPN ARN"
}

output "client_vpn_id" {
  value       = module.vpn.client_vpn_id
  description = "The Keycloak-integrated Client VPN ID"
}

output "server_certificate" {
  value       = module.vpn.server_certificate
  description = "Server certificate ARN (ACM)"
}
