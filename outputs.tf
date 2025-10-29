output "client_vpn_arn" {
  value       = var.client_vpn_config.create ? module.client_vpn[0].client_vpn_arn : null
  description = "The client vpn ARN"
}

output "client_vpn_id" {
  value       = var.client_vpn_config.create ? module.client_vpn[0].client_vpn_arn : null
  description = "The client vpn ID"
}

output "server_certificate" {
  value       = var.client_vpn_config.create ? module.client_vpn[0].server_certificate_arn : null
  description = "Server certificate ARN"
}

output "vpn_gateway_id" {
  value       = var.site_to_site_vpn_config.create ? module.aws_site_to_site_vpn[0].vpn_gateway_id : 0
  description = "The VPN Gateway ID"
  sensitive   = true
}

output "site_to_site_vpn_id" {
  value       = var.site_to_site_vpn_config.create ? module.aws_site_to_site_vpn[0].id : null
  description = "The site to site vpn ID"
  sensitive   = true
}

output "customer_gateway_id" {
  value       = var.site_to_site_vpn_config.create ? module.aws_site_to_site_vpn[0].customer_gateway_id : null
  description = "Customer Gateway ID"
  sensitive   = true
}
