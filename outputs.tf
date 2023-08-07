output "client_vpn_arn" {
  value       = aws_ec2_client_vpn_endpoint.default.arn
  description = "The client vpn ARN"
}

output "client_vpn_id" {
  value       = aws_ec2_client_vpn_endpoint.default.id
  description = "The client vpn ID"
}
