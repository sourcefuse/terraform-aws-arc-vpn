output "client_vpn_arn" {
  value       = module.client_vpn.client_vpn_arn
  description = "The client vpn ARN"
}

output "client_vpn_id" {
  value       = module.client_vpn.client_vpn_arn
  description = "The client vpn ID"
}

output "client_self_signed_cert_server_certificate_arn" {
  value       = module.client_vpn.client_self_signed_cert_server_certificate_arn
  description = "Self signed certificate server certificate ARN"
}
