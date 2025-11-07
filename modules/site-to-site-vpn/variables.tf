variable "environment" {
  type        = string
  description = "Environmenr name"
}

variable "namespace" {
  description = "Namespace name"
  type        = string
}

variable "name" {
  description = "Name for Site to site VPN"
  type        = string
}

variable "customer_gateway_config" {
  type = object({
    bgp_asn         = optional(number, 65000)     # The Border Gateway Protocol (BGP) Autonomous System Number (ASN) Value must be in 1 - 4294967294 range.
    certificate_arn = optional(string, null)      #  The Amazon Resource Name (ARN) for the customer gateway certificate.
    device_name     = optional(string, null)      # A name for the customer gateway device.
    ip_address      = string                      # The IP address of the customer gateway
    type            = optional(string, "ipsec.1") # The type of VPN connection (e.g., 'ipsec.1')
  })
  description = <<-EOT
    Defines the configuration parameters for creating an AWS Customer Gateway, including the BGP ASN, IP address, VPN connection type, and optional certificate or device details.
    - `bgp_asn`: The Border Gateway Protocol (BGP) Autonomous System Number (ASN) required for BGP routing between the VPN and the customer gateway.
    - `certificate_arn`: When required, the ARN of the customer gateway certificate for certificate-based VPN authentication.
    - `device_name`: An optional field for naming or identifying the customer gateway device in your infrastructure.
    - `ip_address`: The public-facing IP address that AWS will use to connect to the customer gateway.
    - `type`: Specifies the type of VPN connection, defaulting to 'ipsec.1' for most use cases.
  EOT
}

variable "vpn_gateway_config" {
  type = object({
    create            = optional(bool, true)
    vpc_id            = string                     # The VPC ID to create the VPN gateway in.
    amazon_side_asn   = optional(number, null)     # The Autonomous System Number (ASN) for the Amazon side of the gateway.
    availability_zone = optional(string, null)     # The Availability Zone for the VPN gateway.
    route_table_ids   = optional(list(string), []) # This resource should not be used with a route table that has the propagating_vgws argument set. If that argument is set, any route propagation not explicitly listed in its value will be removed.
  })
  description = <<-EOT
    Configuration for creating an AWS VPN Gateway. This object allows you to define:
    - `vpc_id`: The VPC ID where the VPN Gateway will be created.
    - `amazon_side_asn`: Optional ASN for the Amazon side of the VPN gateway.
    - `availability_zone`: Optional specification of an availability zone for the VPN Gateway.
    - `route_table_ids` : This resource should not be used with a route table that has the propagating_vgws argument set. If that argument is set, any route propagation not explicitly listed in its value will be removed.
  EOT
}

variable "vpn_connection_config" {
  type = object({
    transit_gateway_id                      = optional(string, null)         # The ID of the transit gateway
    vpn_gateway_id                          = optional(string, null)         # The ID of the Virtual Private Gateway
    static_routes_only                      = optional(bool, false)          # If true, only static routes are used
    enable_acceleration                     = optional(bool, null)           # (Optional, Supports only EC2 Transit Gateway)
    local_ipv4_network_cidr                 = optional(string, "0.0.0.0/0")  # The IPv4 CIDR on the customer gateway side
    local_ipv6_network_cidr                 = optional(string, null)         # The IPv6 CIDR on the customer gateway side
    outside_ip_address_type                 = optional(string, "PublicIpv4") # Public or Private S2S VPN
    remote_ipv4_network_cidr                = optional(string, "0.0.0.0/0")  # The IPv4 CIDR on the AWS side
    remote_ipv6_network_cidr                = optional(string, null)         # The IPv6 CIDR on the AWS side
    transport_transit_gateway_attachment_id = optional(string, null)         # Transit Gateway attachment ID (required for PrivateIpv4)
    tunnel_inside_ip_version                = optional(string, "ipv4")       # IPv4 or IPv6 traffic processing

    # Tunnel configuration options
    tunnel_config = object({
      tunnel1 = object({
        inside_cidr                     = string                                                                     # CIDR block of the first tunnel
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
        inside_cidr                     = string                                                                     # CIDR block of the second tunnel
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

  description = <<-EOT
    Configuration for creating an AWS VPN Connection.
    - `customer_gateway_id`: The ID of the customer gateway.
    - `vpn_gateway_id`: (Optional) The ID of the VPN gateway.
    - `transit_gateway_id`: (Optional) The ID of the transit gateway.
    - `type`: The type of VPN connection, typically 'ipsec.1'.
    - `static_routes_only`: Boolean indicating whether to use static routes only.
    - `tunnel_config`: Configuration for the two tunnels (CIDR blocks, pre-shared keys, encryption and integrity algorithms).
    - `routes`: Optional static routes to add to the VPN connection.
    - `tags`: Key-value pairs to tag the VPN connection.
  EOT

}


# Tagging
variable "tags" {
  type        = map(string)
  description = "Tags to apply to resources."
  default     = {}
}
