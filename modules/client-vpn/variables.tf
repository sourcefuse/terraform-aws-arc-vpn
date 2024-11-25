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

variable "name" {
  type        = string
  description = "The name of the client vpn"
}

variable "self_signed_cert_data" {
  type = object({
    create             = optional(bool, true)
    secret_path_format = optional(string, "/%s.%s")
    server_common_name = optional(string, "")
    organization_name  = optional(string, "")
    allowed_uses = optional(list(string), [
      "key_encipherment",
      "digital_signature",
      "server_auth"
    ])
    ca_pem             = optional(string, "")
    private_ca_key_pem = optional(string, "")
  })
  description = "Data to create certificates"
  default = {
    create = true
  }
}

variable "log_options" {
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

variable "authentication_options" {
  type = list(object({
    active_directory_id            = optional(string, null)
    root_certificate_chain_arn     = optional(string, null)
    saml_provider_arn              = optional(string, null)
    self_service_saml_provider_arn = optional(string, null)
    type                           = string
  }))
  description = <<-EOT
    The type of client authentication to be used.
    Specify certificate-authentication to use certificate-based authentication, directory-service-authentication to use Active Directory authentication,
    or federated-authentication to use Federated Authentication via SAML 2.0.
  EOT

}

variable "security_group_data" {
  type = object({
    additional_security_group_ids = optional(list(string), [])
    ingress_rules = list(object({
      description        = optional(string, "")
      from_port          = number
      to_port            = number
      protocol           = any
      cidr_blocks        = optional(list(string), [])
      security_group_ids = optional(list(string), [])
      ipv6_cidr_blocks   = optional(list(string), [])
    }))
    egress_rules = list(object({
      description        = optional(string, "")
      from_port          = number
      to_port            = number
      protocol           = any
      cidr_blocks        = optional(list(string), [])
      security_group_ids = optional(list(string), [])
      ipv6_cidr_blocks   = optional(list(string), [])
    }))
  })
  description = "Security Group data"
  default = {
    ingress_rules = [
      {
        description = "VPN ingress to 443"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
      }
    ]
    egress_rules = [
      {
        description = "VPN egress to internet"
        from_port   = 0
        to_port     = 0
        protocol    = -1
        cidr_blocks = ["0.0.0.0/0"]
      }
    ]
  }
}

variable "authorization_options" {
  type = map(object({
    target_network_cidr  = string
    access_group_id      = optional(string, null)
    authorize_all_groups = optional(bool, true)
  }))
  description = "Authorization details"
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

variable "split_tunnel" {
  type        = bool
  description = "Indicates whether split-tunnel is enabled on VPN endpoint."
  default     = true
}

variable "self_service_portal" {
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

## network associations
variable "subnet_ids" {
  type        = list(string)
  description = "The ID of the subnets to associate with the Client VPN endpoint."
}

variable "client_cidr_block" {
  type        = string
  description = "Client CICR block"
}


##### ACM ##
variable "use_self_signed_cert" {
  description = "Whether to use a self-signed certificate"
  type        = bool
  default     = true
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

# variable "tags" {
#   description = "Tags to apply to all resources."
#   type        = map(string)
#   default     = {}
# }



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
