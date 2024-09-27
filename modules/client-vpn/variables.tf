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
