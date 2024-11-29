output "ca_cert_pem" {
  value       = var.type == "ca" ? tls_self_signed_cert.ca[0].cert_pem : null
  description = "CA certificate"
}

output "private_key_pem" {
  value       = tls_private_key.this.private_key_pem
  description = "Private Key"
}

output "certificate_arn" {
  value       = var.import_to_acm ? aws_acm_certificate.this[0].arn : null
  description = "ACM certificate ARN"
}
