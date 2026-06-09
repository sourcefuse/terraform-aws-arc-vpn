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

output "saml_client_id" {
  value       = keycloak_saml_client.this.id
  description = "Keycloak internal UUID of the VPN SAML client"
}

output "saml_client_client_id" {
  value       = keycloak_saml_client.this.client_id
  description = "SAML client_id (urn:amazon:webservices:clientvpn)"
}

output "vpn_user_ssm_paths" {
  value       = { for k, v in var.keycloak_config.vpn_users : k => aws_ssm_parameter.vpn_user_password[k].name }
  description = "Map of user key to SSM parameter path containing the initial password"
}
