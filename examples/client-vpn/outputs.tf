output "client_vpn_arn" {
  value       = module.vpn.client_vpn_arn
  description = "The client vpn ARN"
}

output "client_vpn_id" {
  value       = module.vpn.client_vpn_id
  description = "The client vpn ID"
}

output "server_certificate" {
  value       = module.vpn.server_certificate
  description = "Self signed certificate server certificate ARN"
}
