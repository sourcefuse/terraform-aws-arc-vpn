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

output "vpn_connection_arn" {
  description = "Amazon Resource Name (ARN) of the VPN Connection"
  value       = aws_vpn_connection.this.arn
}

output "customer_gateway_configuration" {
  description = "The configuration information for the VPN connection's customer gateway"
  value       = aws_vpn_connection.this.customer_gateway_configuration
}

output "transit_gateway_attachment_id" {
  description = "When associated with an EC2 Transit Gateway, the attachment ID"
  value       = aws_vpn_connection.this.transit_gateway_attachment_id
}

output "tunnel1_address" {
  description = "The public IP address of the first VPN tunnel"
  value       = aws_vpn_connection.this.tunnel1_address
}

output "tunnel1_cgw_inside_address" {
  description = "The RFC 6890 link-local address of the first VPN tunnel (Customer Gateway Side)"
  value       = aws_vpn_connection.this.tunnel1_cgw_inside_address
}

output "tunnel1_vgw_inside_address" {
  description = "The RFC 6890 link-local address of the first VPN tunnel (VPN Gateway Side)"
  value       = aws_vpn_connection.this.tunnel1_vgw_inside_address
}

output "tunnel1_preshared_key" {
  description = "The preshared key of the first VPN tunnel"
  value       = aws_vpn_connection.this.tunnel1_preshared_key
  sensitive   = true
}

output "tunnel1_bgp_asn" {
  description = "The bgp asn number of the first VPN tunnel"
  value       = aws_vpn_connection.this.tunnel1_bgp_asn
}

output "tunnel1_bgp_holdtime" {
  description = "The bgp holdtime of the first VPN tunnel"
  value       = aws_vpn_connection.this.tunnel1_bgp_holdtime
}

output "tunnel2_address" {
  description = "The public IP address of the second VPN tunnel"
  value       = aws_vpn_connection.this.tunnel2_address
}

output "tunnel2_cgw_inside_address" {
  description = "The RFC 6890 link-local address of the second VPN tunnel (Customer Gateway Side)"
  value       = aws_vpn_connection.this.tunnel2_cgw_inside_address
}

output "tunnel2_vgw_inside_address" {
  description = "The RFC 6890 link-local address of the second VPN tunnel (VPN Gateway Side)"
  value       = aws_vpn_connection.this.tunnel2_vgw_inside_address
}

output "tunnel2_preshared_key" {
  description = "The preshared key of the second VPN tunnel"
  value       = aws_vpn_connection.this.tunnel2_preshared_key
  sensitive   = true
}

output "tunnel2_bgp_asn" {
  description = "The bgp asn number of the second VPN tunnel"
  value       = aws_vpn_connection.this.tunnel2_bgp_asn
}

output "tunnel2_bgp_holdtime" {
  description = "The bgp holdtime of the second VPN tunnel"
  value       = aws_vpn_connection.this.tunnel2_bgp_holdtime
}

output "vgw_telemetry" {
  description = "Telemetry for the VPN tunnels"
  value       = aws_vpn_connection.this.vgw_telemetry
}

output "routes" {
  description = "The static routes associated with the VPN connection"
  value       = aws_vpn_connection.this.routes
}
