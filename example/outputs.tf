output "client_vpn_arn" {
  value       = aws_ec2_client_vpn_endpoint.this.arn
  description = "The client vpn ARN"
}

output "client_vpn_id" {
  value       = aws_ec2_client_vpn_endpoint.this.id
  description = "The client vpn ID"
}

output "client_vpn_server_certificate_arn" {
  value = module.acm_request_server_certificate.arn
}

output "client_vpn_auth_root_certificate_arn" {
  value = module.acm_request_root_certificate.arn
}
