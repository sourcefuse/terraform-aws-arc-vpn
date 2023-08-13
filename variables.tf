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
  type = list(object({
    description        = optional(string, "")
    from_port          = number
    to_port            = number
    protocol           = any
    cidr_blocks        = optional(list(string), [])
    security_group_ids = optional(list(string), [])
    ipv6_cidr_blocks   = optional(list(string), [])
  }))
  description = "Ingress rules for the security groups."
  default = [
    {
      description = "VPN ingress to 443"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
    }
  ]
}

variable "client_vpn_egress_rules" {
  type = list(object({
    description        = optional(string, "")
    from_port          = number
    to_port            = number
    protocol           = any
    cidr_blocks        = optional(list(string), [])
    security_group_ids = optional(list(string), [])
    ipv6_cidr_blocks   = optional(list(string), [])
  }))
  description = "Egress rules for the security groups."
  default = [
    {
      description = "VPN egress to internet"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

################################################################################
## certs
################################################################################
variable "create_self_signed_server_cert" {
  type        = bool
  description = "Create a self signed certificate to use for the VPN server."
  default     = true
}

variable "self_signed_server_cert_secret_path_format" {
  description = "The path format to use when writing secrets to the certificate backend."
  type        = string
  default     = "/%s.%s"

  validation {
    condition     = can(substr(var.self_signed_server_cert_secret_path_format, 0, 1) == "/")
    error_message = "The secret path format must contain a leading slash."
  }
}

variable "self_signed_server_cert_server_common_name" {
  type        = string
  description = "Common name to assign the server certificate"
  default     = ""
}

variable "self_signed_server_cert_organization_name" {
  type        = string
  description = "Organization name to assign the server certificate"
  default     = ""
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

variable "self_signed_server_cert_ca_pem" {
  type        = string
  description = "Server certificate CA PEM"
  default     = ""
}

variable "self_signed_server_cert_private_ca_key_pem" {
  type        = string
  description = "Server certificate Private Key PEM"
  sensitive   = true
  default     = ""
}

################################################################################
## vpn
################################################################################
variable "client_vpn_name" {
  type        = string
  description = "The name of the client vpn"
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
  default     = null
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

## network associations
variable "client_vpn_subnet_ids" {
  type        = list(string)
  description = "The ID of the subnets to associate with the Client VPN endpoint."
}

## authorization
variable "client_vpn_target_network_cidr" {
  type        = string
  description = "The IPv4 address range, in CIDR notation, of the network to which the authorization rule applies."
}

variable "client_vpn_access_group_id" {
  type        = string
  description = "The ID of the group to which the authorization rule grants access. One of access_group_id or authorize_all_groups must be set."
  default     = null
}

variable "client_vpn_authorize_all_groups" {
  type        = bool
  description = "Indicates whether the authorization rule grants access to all clients. One of access_group_id or authorize_all_groups must be set."
  default     = true
}
