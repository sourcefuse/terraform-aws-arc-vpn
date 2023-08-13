output "client_vpn_arn" {
  value       = aws_ec2_client_vpn_endpoint.this.arn
  description = "The client vpn ARN"
}

output "client_vpn_id" {
  value       = aws_ec2_client_vpn_endpoint.this.id
  description = "The client vpn ID"
}

output "client_self_signed_cert_server_certificate_arn" {
  value = var.create_self_signed_server_cert == true ? module.self_signed_cert.certificate_arn : null
  description = "Self signed certificate server certificate ARN"
}
