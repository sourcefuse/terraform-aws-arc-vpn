output "client_vpn_arn" {
  value       = aws_ec2_client_vpn_endpoint.this.arn
  description = "The client vpn ARN"
}

output "client_vpn_id" {
  value       = aws_ec2_client_vpn_endpoint.this.id
  description = "The client vpn ID"
}
