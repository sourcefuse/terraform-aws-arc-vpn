locals {
  # Determine if a Private Key is Required
  private_key_required = var.generate_private_key || var.private_key == ""
}

# Resource: Generate a Private Key (Optional)
resource "tls_private_key" "generated_key" {
  count     = local.private_key_required ? 1 : 0
  algorithm = var.private_key_algorithm

  rsa_bits    = var.private_key_algorithm == "RSA" ? var.rsa_bits : null
  ecdsa_curve = var.private_key_algorithm == "ECDSA" ? var.ecdsa_curve : null

}

# Resource: Generate a Certificate Signing Request (CSR)
resource "tls_cert_request" "csr" {
  count = var.create_certificate_request ? 1 : 0

  private_key_pem = local.private_key_required ? tls_private_key.generated_key[0].private_key_pem : var.private_key

  subject {
    common_name         = var.subject_common_name
    organization        = var.subject_organization
    organizational_unit = var.subject_organizational_unit
    country             = var.subject_country
    locality            = var.subject_locality
    province            = var.subject_province
    postal_code         = var.subject_postal_code
    serial_number       = var.subject_serial_number
    street_address      = var.subject_street_address
  }

  dns_names    = var.additional_dns_names
  ip_addresses = var.additional_ip_addresses
  uris         = var.additional_uris
}

# Resource: Generate a Locally Signed Certificate
resource "tls_locally_signed_cert" "local_cert" {
  count = var.use_locally_signed_cert ? 1 : 0

  cert_request_pem   = tls_cert_request.csr[0].cert_request_pem
  ca_private_key_pem = var.ca_private_key
  ca_cert_pem        = var.ca_certificate

  validity_period_hours = var.certificate_validity_hours
  early_renewal_hours   = var.early_renewal_hours
  is_ca_certificate     = var.is_ca
  set_subject_key_id    = var.set_subject_key_id

  allowed_uses = var.allowed_uses
}

# Resource: Generate a Self-Signed Certificate
resource "tls_self_signed_cert" "self_signed_cert" {
  count = var.use_self_signed_cert ? 1 : 0

  private_key_pem = local.private_key_required ? tls_private_key.generated_key[0].private_key_pem : var.private_key

  validity_period_hours = var.certificate_validity_hours
  early_renewal_hours   = var.early_renewal_hours
  is_ca_certificate     = var.is_ca
  set_authority_key_id  = var.set_authority_key_id
  set_subject_key_id    = var.set_subject_key_id

  allowed_uses = var.allowed_uses

  subject {
    common_name         = var.subject_common_name
    organization        = var.subject_organization
    organizational_unit = var.subject_organizational_unit
    country             = var.subject_country
    locality            = var.subject_locality
    province            = var.subject_province
    postal_code         = var.subject_postal_code
    serial_number       = var.subject_serial_number
    street_address      = var.subject_street_address
  }

  dns_names    = var.additional_dns_names
  ip_addresses = var.additional_ip_addresses
  uris         = var.additional_uris
}

# Resource: Create an ACM Certificate in AWS
resource "aws_acm_certificate" "example" {
  private_key      = tls_private_key.generated_key[0].private_key_pem
  certificate_body = tls_self_signed_cert.self_signed_cert[0].cert_pem
}


######################################################################################

resource "aws_ssm_parameter" "certificate" {
  name   = format(var.secret_path_format, var.certificate_name_prefix, var.secret_extensions.certificate)
  type   = "SecureString"
  value  = var.use_locally_signed_cert ? tls_locally_signed_cert.local_cert[0].cert_pem : (var.use_self_signed_cert ? tls_self_signed_cert.self_signed_cert[0].cert_pem : aws_acm_certificate.example.arn)
  tags   = var.tags
}

resource "aws_ssm_parameter" "private_key" {
  name   = format(var.secret_path_format, var.private_key_name_prefix, var.secret_extensions.private_key)
  type   = "SecureString"
  value  = local.private_key_required ? tls_private_key.generated_key[0].private_key_pem : var.private_key
  tags   = var.tags
}


variable "secret_extensions" {
  description = "Extensions for secret naming"
  type = object({
    certificate = string
    private_key = string
  })
  default = {
    certificate = "cert"
    private_key = "key"
  }
}

variable "secret_path_format" {
  description = "The format for the secret path."
  type        = string
  default     = "%s/%s"
}

variable "certificate_name_prefix" {
  description = "The prefix for the certificate SSM parameter name."
  type        = string
  default = "cert-name-prefix"
}

variable "private_key_name_prefix" {
  description = "The prefix for the private key SSM parameter name."
  type        = string
  default = "key-prefix"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}



################################# Variables #########################################
variable "generate_private_key" {
  description = "Whether to generate a new private key"
  type        = bool
  default     = true
}

variable "private_key" {
  description = "PEM-encoded private key (used if `generate_private_key` is false)"
  type        = string
  default     = ""
}

variable "private_key_algorithm" {
  description = "Algorithm to use for the private key (e.g., RSA, ECDSA)"
  type        = string
  default     = "RSA"
}

variable "rsa_bits" {
  description = "The size of the RSA key to generate (if RSA is selected)"
  type        = number
  default     = 2048
}

variable "ecdsa_curve" {
  description = "The ECDSA curve to use (if ECDSA is selected)"
  type        = string
  default     = "P256"
}

variable "create_certificate_request" {
  description = "Whether to create a certificate signing request (CSR)"
  type        = bool
  default     = false
}

variable "use_locally_signed_cert" {
  description = "Whether to use a locally signed certificate"
  type        = bool
  default     = false
}

variable "use_self_signed_cert" {
  description = "Whether to use a self-signed certificate"
  type        = bool
  default     = true
}

variable "ca_private_key" {
  description = "CA private key PEM for signing locally signed certificates"
  type        = string
  default     = ""
}

variable "ca_certificate" {
  description = "CA certificate PEM for signing locally signed certificates"
  type        = string
  default     = ""
}

variable "certificate_validity_hours" {
  description = "Validity period of the certificate in hours"
  type        = number
  default     = 8760 # 1 year
}

variable "is_ca" {
  description = "Whether the certificate is a CA certificate"
  type        = bool
  default     = false
}

variable "allowed_uses" {
  description = "List of allowed uses for the certificate"
  type        = list(string)
  default     = ["digital_signature", "key_encipherment"]
}

variable "subject_common_name" {
  description = "Common name (CN) for the certificate subject"
  type        = string
  default     = "arc-test-refactor-vpn.com"
}

variable "subject_organization" {
  description = "Organization (O) for the certificate subject"
  type        = string
  default     = "Example Org"
}

variable "subject_organizational_unit" {
  description = "Distinguished name: OU (Organizational Unit)."
  type        = string
  default     = null
}

variable "subject_locality" {
  description = "Distinguished name: L (Locality)."
  type        = string
  default     = null
}

variable "subject_province" {
  description = "Distinguished name: ST (Province/State)."
  type        = string
  default     = null
}

variable "subject_postal_code" {
  description = "Distinguished name: PC (Postal Code)."
  type        = string
  default     = null
}

variable "subject_serial_number" {
  description = "Distinguished name: SERIALNUMBER."
  type        = string
  default     = null
}

variable "subject_street_address" {
  description = "Distinguished name: STREET (Street Address)."
  type        = list(string)
  default     = []
}

variable "subject_country" {
  description = "Country (C) for the certificate subject"
  type        = string
  default     = "US"
}

variable "additional_dns_names" {
  description = "List of additional DNS names for the certificate"
  type        = list(string)
  default     = []
}

variable "additional_ip_addresses" {
  description = "List of additional IP addresses for the certificate"
  type        = list(string)
  default     = []
}


variable "additional_uris" {
  description = "List of URIs for which a certificate is being requested."
  type        = list(string)
  default     = []
}

variable "early_renewal_hours" {
  description = "Number of hours before expiration to consider the certificate ready for renewal"
  type        = number
  default     = 0
}

variable "set_subject_key_id" {
  description = "Whether to include a subject key identifier in the generated certificate"
  type        = bool
  default     = false
}

variable "set_authority_key_id" {
  description = "Whether to include an authority key identifier in the certificate."
  type        = bool
  default     = false
}



########################################## Output ####################################
output "certificate_pem" {
  value = var.use_locally_signed_cert ? tls_locally_signed_cert.local_cert[0].cert_pem : tls_self_signed_cert.self_signed_cert[0].cert_pem
}

output "private_key_pem" {
  value     = local.private_key_required ? tls_private_key.generated_key[0].private_key_pem : var.private_key
  sensitive = true
}

output "certificate_pem_01" {
  value = var.use_locally_signed_cert ? (length(tls_locally_signed_cert.local_cert) > 0 ? tls_locally_signed_cert.local_cert[0].cert_pem : null) : (length(tls_self_signed_cert.self_signed_cert) > 0 ? tls_self_signed_cert.self_signed_cert[0].cert_pem : null)
}