################################################################################
## shared
################################################################################
variable "environment" {
  type        = string
  description = "Environmenr name"
}

variable "namespace" {
  description = "Namespace name"
  type        = string
}

variable "name" {
  type        = string
  description = "Name of Client VPN or Site to site VPN"
}

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
    create = optional(bool, false)
    # certs
    server_certificate_data = optional(object({
      create       = optional(bool, true)
      common_name  = string
      organization = string
      allowed_uses = optional(list(string), [
        "key_encipherment",
        "digital_signature",
        "server_auth"
      ])
      ca_cert_pem        = string
      ca_private_key_pem = string
      certificate_arn    = optional(string, null)
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

    transport_protocol = optional(string, "tcp")

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
  default = {
    create                 = false
    authentication_options = null
    authorization_options  = null
    client_cidr_block      = null
    subnet_ids             = []
  }
}

variable "site_to_site_vpn_config" {
  type = object({
    create = optional(bool, false)
    customer_gateway = object({
      bgp_asn         = optional(number, 65000)     # The Border Gateway Protocol (BGP) Autonomous System Number (ASN) Value must be in 1 - 4294967294 range.
      certificate_arn = optional(string, null)      # The Amazon Resource Name (ARN) for the customer gateway certificate.
      device_name     = optional(string, null)      # A name for the customer gateway device.
      ip_address      = string                      # The IP address of the customer gateway
      type            = optional(string, "ipsec.1") # The type of VPN connection (e.g., 'ipsec.1')
    })

    vpn_gateway = object({
      create            = optional(bool, true)
      vpc_id            = string                     # The VPC ID to create the VPN gateway in.
      amazon_side_asn   = optional(number, null)     # The Autonomous System Number (ASN) for the Amazon side of the gateway.
      availability_zone = optional(string, null)     # The Availability Zone for the VPN gateway.
      route_table_ids   = optional(list(string), []) # This resource should not be used with a route table that has the propagating_vgws argument set. If that argument is set, any route propagation not explicitly listed in its value will be removed.
    })

    vpn_connection = object({
      transit_gateway_id                      = optional(string, null)         # The ID of the transit gateway
      vpn_gateway_id                          = optional(string, null)         # The ID of the Virtual Private Gateway
      static_routes_only                      = optional(bool, false)          # If true, only static routes are used
      enable_acceleration                     = optional(bool, null)           # (Optional, Default false) Indicate whether to enable acceleration for the VPN connection. Supports only EC2 Transit Gateway.
      local_ipv4_network_cidr                 = optional(string, "0.0.0.0/0")  # The IPv4 CIDR on the customer gateway side
      local_ipv6_network_cidr                 = optional(string, null)         # The IPv6 CIDR on the customer gateway side
      outside_ip_address_type                 = optional(string, "PublicIpv4") # Public or Private S2S VPN
      remote_ipv4_network_cidr                = optional(string, "0.0.0.0/0")  # The IPv4 CIDR on the AWS side
      remote_ipv6_network_cidr                = optional(string, null)         # The IPv6 CIDR on the AWS side
      transport_transit_gateway_attachment_id = optional(string, null)         # Transit Gateway attachment ID (required for PrivateIpv4)
      tunnel_inside_ip_version                = optional(string, "ipv4")       # IPv4 or IPv6 traffic processing

      tunnel_config = object({
        tunnel1 = object({
          inside_cidr                     = optional(string, null)                                                     # CIDR block of the first tunnel
          inside_ipv6_cidr                = optional(string, null)                                                     # IPv6 CIDR block of the first tunnel
          preshared_key                   = optional(string, null)                                                     # Pre-shared key for the first tunnel
          dpd_timeout_action              = optional(string, "clear")                                                  # DPD timeout action: clear, none, restart
          dpd_timeout_seconds             = optional(number, 30)                                                       # DPD timeout in seconds (>=30)
          enable_tunnel_lifecycle_control = optional(bool, false)                                                      # Turn on/off tunnel endpoint lifecycle control
          ike_versions                    = optional(list(string), ["ikev1", "ikev2"])                                 # IKE versions: ikev1, ikev2
          phase1_dh_group_numbers         = optional(list(number), [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])    # Phase 1 DH group numbers
          phase1_encryption_algorithms    = optional(list(string), ["AES128", "AES256"])                               # Phase 1 encryption algorithms
          phase1_integrity_algorithms     = optional(list(string), ["SHA1", "SHA2-256"])                               # Phase 1 integrity algorithms
          phase1_lifetime_seconds         = optional(number, 28800)                                                    # Phase 1 lifetime (900-28800)
          phase2_dh_group_numbers         = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]) # Phase 2 DH group numbers
          phase2_encryption_algorithms    = optional(list(string), ["AES128", "AES256"])                               # Phase 2 encryption algorithms
          phase2_integrity_algorithms     = optional(list(string), ["SHA1", "SHA2-256"])                               # Phase 2 integrity algorithms
          phase2_lifetime_seconds         = optional(number, 3600)                                                     # Phase 2 lifetime (900-3600)
          rekey_fuzz_percentage           = optional(number, 100)                                                      # Rekey fuzz percentage (0-100)
          rekey_margin_time_seconds       = optional(number, 540)                                                      # Rekey margin time (60 to half of phase2_lifetime)
          replay_window_size              = optional(number, 1024)                                                     # Replay window size (64-2048)
          startup_action                  = optional(string, "add")                                                    # Startup action: add, start
          log_enabled                     = optional(bool, false)                                                      # Enable VPN tunnel logging
          log_group_arn                   = optional(string, null)                                                     # CloudWatch log group ARN
          log_group_kms_arn               = optional(string, null)                                                     # KMS key for log encryption
          log_output_format               = optional(string, "json")                                                   # Log format: json, text
          log_retention_in_days           = optional(number, 7)                                                        # Log retention period
        })

        tunnel2 = object({
          inside_cidr                     = optional(string, null)                                                     # CIDR block of the second tunnel
          inside_ipv6_cidr                = optional(string, null)                                                     # IPv6 CIDR block of the second tunnel
          preshared_key                   = optional(string, null)                                                     # Pre-shared key for the second tunnel
          dpd_timeout_action              = optional(string, "clear")                                                  # DPD timeout action: clear, none, restart
          dpd_timeout_seconds             = optional(number, 30)                                                       # DPD timeout in seconds (>=30)
          enable_tunnel_lifecycle_control = optional(bool, false)                                                      # Turn on/off tunnel endpoint lifecycle control
          ike_versions                    = optional(list(string), ["ikev1", "ikev2"])                                 # IKE versions: ikev1, ikev2
          phase1_dh_group_numbers         = optional(list(number), [2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24])    # Phase 1 DH group numbers
          phase1_encryption_algorithms    = optional(list(string), ["AES128", "AES256"])                               # Phase 1 encryption algorithms
          phase1_integrity_algorithms     = optional(list(string), ["SHA1", "SHA2-256"])                               # Phase 1 integrity algorithms
          phase1_lifetime_seconds         = optional(number, 28800)                                                    # Phase 1 lifetime (900-28800)
          phase2_dh_group_numbers         = optional(list(number), [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]) # Phase 2 DH group numbers
          phase2_encryption_algorithms    = optional(list(string), ["AES128", "AES256"])                               # Phase 2 encryption algorithms
          phase2_integrity_algorithms     = optional(list(string), ["SHA1", "SHA2-256"])                               # Phase 2 integrity algorithms
          phase2_lifetime_seconds         = optional(number, 3600)                                                     # Phase 2 lifetime (900-3600)
          rekey_fuzz_percentage           = optional(number, 100)                                                      # Rekey fuzz percentage (0-100)
          rekey_margin_time_seconds       = optional(number, 540)                                                      # Rekey margin time (60 to half of phase2_lifetime)
          replay_window_size              = optional(number, 1024)                                                     # Replay window size (64-2048)
          startup_action                  = optional(string, "add")                                                    # Startup action: add, start
          log_enabled                     = optional(bool, false)                                                      # Enable VPN tunnel logging
          log_group_arn                   = optional(string, null)                                                     # CloudWatch log group ARN
          log_group_kms_arn               = optional(string, null)                                                     # KMS key for log encryption
          log_output_format               = optional(string, "json")                                                   # Log format: json, text
          log_retention_in_days           = optional(number, 7)                                                        # Log retention period
        })
      })
      # VPN routes configuration (only for static routes)
      routes = optional(list(object({
        destination_cidr_block = string # The CIDR block to route through the VPN
      })), [])
    })
  })

  description = <<-EOT
    Configuration for AWS VPN setup combining customer gateway, VPN gateway, and VPN connection configurations. This structure provides a comprehensive approach to defining all necessary parameters for establishing a Site-to-Site VPN.
  EOT
  default = {
    create           = false
    customer_gateway = null
    vpn_gateway      = null
    vpn_connection   = null
  }
  sensitive = true
}
