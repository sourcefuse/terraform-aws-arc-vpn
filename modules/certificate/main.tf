resource "tls_private_key" "this" {
  algorithm = "RSA"
}

resource "tls_cert_request" "this" {
  count = var.type == "ca" ? 0 : 1

  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = var.subject.common_name
    organization = var.subject.organization
  }
}

resource "tls_self_signed_cert" "ca" {
  count = var.type == "ca" ? 1 : 0

  private_key_pem = tls_private_key.this.private_key_pem

  subject {
    common_name  = var.subject.common_name
    organization = var.subject.organization
  }

  validity_period_hours = var.validity_period_hours
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_locally_signed_cert" "this" {
  count = var.type == "ca" ? 0 : 1

  cert_request_pem   = tls_cert_request.this[0].cert_request_pem
  ca_private_key_pem = var.ca_private_key_pem
  ca_cert_pem        = var.ca_cert_pem

  validity_period_hours = var.validity_period_hours

  allowed_uses = length(var.allowed_uses) == 0 ? local.allowed_uses_map[var.type] : var.allowed_uses
}

resource "aws_acm_certificate" "this" {
  count = var.import_to_acm ? 1 : 0

  private_key       = tls_private_key.this.private_key_pem
  certificate_body  = var.type == "ca" ? tls_self_signed_cert.ca[0].cert_pem : tls_locally_signed_cert.this[0].cert_pem
  certificate_chain = var.type == "ca" ? null : var.ca_cert_pem
}

resource "aws_ssm_parameter" "private_key" {
  count = var.store_in_ssm ? 1 : 0

  name        = "/${var.namespace}/${var.environment}/${var.name}/${var.subject.common_name}/${var.type}/private-key"
  description = "Private key for the certificate"
  type        = "SecureString"
  value       = tls_private_key.this.private_key_pem
  tags        = var.tags
}

resource "aws_ssm_parameter" "cert" {
  count = var.store_in_ssm ? 1 : 0

  name        = "/${var.namespace}/${var.environment}/${var.name}/${var.subject.common_name}/${var.type}/cert"
  description = "Certificate body for the certificate"
  type        = "SecureString"
  value       = var.type == "ca" ? tls_self_signed_cert.ca[0].cert_pem : tls_locally_signed_cert.this[0].cert_pem
  tags        = var.tags
}

resource "local_file" "private_key" {
  count = var.store_it_locally ? 1 : 0

  content  = tls_private_key.this.private_key_pem
  filename = "${var.name}-${var.type}-${var.subject.common_name}-private-key.pem"
}

resource "local_file" "cert_file" {
  count    = var.store_it_locally ? 1 : 0
  content  = var.type == "ca" ? tls_self_signed_cert.ca[0].cert_pem : tls_locally_signed_cert.this[0].cert_pem
  filename = "${var.name}-${var.type}-${var.subject.common_name}-cert.pem"
}
