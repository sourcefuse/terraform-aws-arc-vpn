output "vpn_gateway_id" {
  value       = var.vpn_gateway_config.create ? aws_vpn_gateway.this[0].id : 0
  description = "The VPN Gateway ID"
}

output "id" {
  value       = aws_vpn_connection.this.id
  description = "The site to site vpn ID"
}

output "customer_gateway_id" {
  value       = aws_customer_gateway.this.id
  description = "Customer Gateway ID"
}
