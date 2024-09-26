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

variable "client_vpn_config" {
  description = "VPN configuration options including certs and vpn settings"
  type = object({
    name   = string
    create = optional(bool, false)
    # certs
    self_signed_cert_data = optional(object({
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
    }))


    # vpn settings
    iam_saml_provider_enabled      = optional(bool, false)
    iam_saml_provider_name         = optional(string, null)
    saml_metadata_document_content = optional(string, null)
    client_cidr_block              = string
    split_tunnel                   = optional(bool, true)
    self_service_portal            = optional(string, "disabled")
    dns_servers                    = optional(list(string), ["1.1.1.1", "1.0.0.1"])

    # logging options
    log_options = optional(object({
      enabled               = bool
      cloudwatch_log_stream = optional(string, null)
      cloudwatch_log_group  = optional(string, null)
      }), {
      enabled = false
    })

    # authentication options
    authentication_options = list(object({
      active_directory_id            = optional(string, null)
      root_certificate_chain_arn     = optional(string, null)
      saml_provider_arn              = optional(string, null)
      self_service_saml_provider_arn = optional(string, null)
      type                           = string
    }))

    # server and transport protocol
    client_server_certificate_arn    = optional(string, null)
    client_server_transport_protocol = optional(string, "tcp")

    # security and network associations
    security_group_data = optional(object({
      client_vpn_additional_security_group_ids = optional(list(string), [])
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
      }),
      {
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
    )

    subnet_ids = list(string)

    # authorization options
    authorization_options = map(object({
      target_network_cidr  = string
      access_group_id      = optional(string, null)
      authorize_all_groups = optional(bool, true)
    }))
  })
}
