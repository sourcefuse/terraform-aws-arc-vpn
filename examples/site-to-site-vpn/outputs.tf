output "vpn_gateway_id" {
  value       = nonsensitive(module.vpn.vpn_gateway_id)
  description = "The VPN Gateway ID"
}

output "site_to_site_vpn_id" {
  value       = nonsensitive(module.vpn.site_to_site_vpn_id)
  description = "The site to site vpn ID"
}

output "customer_gateway_id" {
  value       = nonsensitive(module.vpn.customer_gateway_id)
  description = "Customer Gateway ID"
}
