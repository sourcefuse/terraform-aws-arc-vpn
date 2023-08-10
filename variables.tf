################################################################################
## shared
################################################################################
variable "tags" {
  type        = map(string)
  description = "Default tags to apply to every applicable resource"
}

variable "vpc_id" {
  type        = string
  description = "The ID of the target network VPC"
}

################################################################################
## security
################################################################################
variable "client_vpn_ingress_rules" {
  type = map(object({
    description       = optional(string)
    from_port         = number
    to_port           = number
    protocol          = string
    cidr_blocks       = optional(list(string))
    security_group_id = optional(list(string))
    ipv6_cidr_blocks  = optional(list(string))
    self              = optional(bool)
  }))
  description = "Ingress rules for the security groups."
  default     = {}
}

variable "client_vpn_egress_rules" {
  type = map(object({
    description       = optional(string)
    from_port         = number
    to_port           = number
    protocol          = string
    cidr_blocks       = optional(list(string))
    security_group_id = optional(list(string))
    ipv6_cidr_blocks  = optional(list(string))
  }))
  description = "Egress rules for the security groups."
  default     = {}
}

################################################################################
## certs
################################################################################
variable "create_self_signed_server_cert" {
  type        = bool
  description = "Create a self signed certificate to use for the VPN server."
  default     = true
}

variable "self_signed_server_cert_name" {
  type        = string
  description = "Name to assign the Self-Signed certificate for the VPN Server."
  default     = "client-vpn-server-self-signed-certificate"
}

variable "self_signed_server_cert_subject" {
  description = <<-EOT
    The subject configuration for the certificate.
    This should be a map that is compatible with [tls_cert_request.subject](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request#subject).
  EOT
  type        = any
  default     = {}
}

variable "self_signed_server_cert_validity" {
  description = <<-EOT
    Validity settings for the issued certificate:

    `duration_hours`: The number of hours from issuing the certificate until it becomes invalid.
    `early_renewal_hours`: If set, the resource will consider the certificate to have expired the given number of hours before its actual expiry time (see: [self_signed_cert.early_renewal_hours](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert#early_renewal_hours)).

    Defaults to 10 years and no early renewal hours.
  EOT
  type = object({
    duration_hours      = number
    early_renewal_hours = number
  })
  default = {
    duration_hours      = 87600
    early_renewal_hours = null
  }
}

variable "self_signed_server_cert_allowed_uses" {
  description = <<-EOT
    List of keywords each describing a use that is permitted for the issued certificate.
    Must be one of of the values outlined in [self_signed_cert.allowed_uses](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert#allowed_uses).
  EOT
  type        = list(string)
  default = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
}

variable "self_signed_server_cert_subject_alt_names" {
  description = <<-EOT
    The subject alternative name (SAN) configuration for the certificate. This configuration consists of several lists, each of which can also be set to `null` or `[]`.

    `dns_names`: List of DNS names for which a certificate is being requested.
    `ip_addresses`: List of IP addresses for which a certificate is being requested.
    `uris`: List of URIs for which a certificate is being requested.

    Defaults to no SANs.
  EOT
  type = object({
    dns_names    = optional(list(string), null)
    ip_addresses = optional(list(string), null)
    uris         = optional(list(string), null)
  })
  default = {}
}

################################################################################
## vpn
################################################################################
variable "client_vpn_name" {
  type        = string
  description = "The name of the client vpn"
  default     = "client-vpn-01"
}

## gateway
variable "client_vpn_gateway_name" {
  type        = string
  description = "The name of the client vpn gateway."
}

## saml provider
variable "iam_saml_provider_enabled" {
  type        = bool
  description = "Enable the SAML provider for SSO login to Client VPN. If enabled, `var.iam_saml_provider_name` and `var.saml_metadata_document_content` must be set."
  default     = false
}

variable "iam_saml_provider_name" {
  type        = string
  description = "The name of the IAM SAML Provider"
  default     = ""
}

variable "saml_metadata_document_content" {
  type        = string
  description = "The content of the saml metadata document"
  default     = null
}

## endpoint
variable "client_cidr" {
  type        = string
  description = "The IPv4 address range, in CIDR notation, from which to assign client IP addresses."
}

variable "client_vpn_split_tunnel" {
  type        = bool
  description = "Indicates whether split-tunnel is enabled on VPN endpoint."
  default     = true
}

variable "client_vpn_self_service_portal" {
  type        = string
  description = "Specify whether to enable the self-service portal for the Client VPN endpoint. Values can be enabled or disabled."
  default     = "disabled"
}

variable "dns_servers" {
  type        = list(string)
  description = "The list of dns server ip address"
  default = [
    "1.1.1.1",
    "1.0.0.1"
  ]
}

variable "client_vpn_log_options" {
  description = "Whether logging is enabled and where to send the logs output."
  type = object({
    enabled               = bool                   // Indicates whether connection logging is enabled
    cloudwatch_log_stream = optional(string, null) // The name of the vpn client cloudwatch log stream
    cloudwatch_log_group  = optional(string, null) // The name of the vpn client cloudwatch log group
  })
  default = {
    enabled = false
  }
}

variable "authentication_options_active_directory_id" {
  type        = string
  description = "The ID of the Active Directory to be used for authentication if type is directory-service-authentication."
  default     = null
}

variable "authentication_options_root_certificate_chain_arn" {
  type        = string
  description = "The ARN of the client certificate. The certificate must be signed by a certificate authority (CA) and it must be provisioned in AWS Certificate Manager (ACM). Only necessary when type is set to certificate-authentication."
  default     = null
}

variable "authentication_options_saml_provider_arn" {
  type        = string
  description = "The ARN of the IAM SAML identity provider if type is federated-authentication."
  default     = null
}

variable "authentication_options_self_service_saml_provider_arn" {
  type        = string
  description = "The ARN of the IAM SAML identity provider for the self service portal if type is federated-authentication."
  default     = null
}

variable "authentication_options_type" {
  type        = string
  description = <<-EOT
    The type of client authentication to be used.
    Specify certificate-authentication to use certificate-based authentication, directory-service-authentication to use Active Directory authentication,
    or federated-authentication to use Federated Authentication via SAML 2.0.
  EOT
  default     = "federated-authentication"
}

variable "client_server_certificate_arn" {
  type        = string
  description = "The ARN of the ACM server certificate."
  default     = null
}

variable "client_server_transport_protocol" {
  type        = string
  description = "The transport protocol to be used by the VPN session."
  default     = "tcp"
}

variable "client_vpn_additional_security_group_ids" {
  type        = list(string)
  description = "Additional IDs of security groups to add to the target network."
  default     = []
}
