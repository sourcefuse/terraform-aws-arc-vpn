# VPN Tunnel Configuration Guide

This document provides comprehensive guidance on configuring VPN tunnels with all available dynamic parameters based on the AWS VPN Connection resource.

## Overview

The module now supports all AWS VPN tunnel configuration parameters, making it fully dynamic and allowing fine-grained control over VPN tunnel behavior, security, and performance.

## Configuration Structure

### Basic VPN Connection Parameters

```hcl
vpn_connection = {
  transit_gateway_id                      = "tgw-12345678"           # Optional: Transit Gateway ID
  vpn_gateway_id                          = "vgw-12345678"           # Optional: VPN Gateway ID (if not creating new)
  static_routes_only                      = true                     # Use static routes only
  enable_acceleration                     = false                    # Enable acceleration (Transit Gateway only)
  preshared_key_storage                   = "Standard"               # "Standard" or "SecretsManager"
  local_ipv4_network_cidr                 = "10.0.0.0/16"           # Customer gateway side CIDR
  local_ipv6_network_cidr                 = "::/0"                  # Customer gateway side IPv6 CIDR
  outside_ip_address_type                 = "PublicIpv4"            # "PublicIpv4" or "PrivateIpv4"
  remote_ipv4_network_cidr                = "172.16.0.0/16"         # AWS side CIDR
  remote_ipv6_network_cidr                = "::/0"                  # AWS side IPv6 CIDR
  transport_transit_gateway_attachment_id = "tgw-attach-12345678"   # Required for PrivateIpv4
  tunnel_inside_ip_version                = "ipv4"                  # "ipv4" or "ipv6"
}
```

### Tunnel Configuration Parameters

Each tunnel (tunnel1 and tunnel2) supports the following parameters:

#### Basic Tunnel Settings

```hcl
tunnel1 = {
  # CIDR Configuration
  inside_cidr      = "169.254.1.0/30"    # /30 CIDR from 169.254.0.0/16 range
  inside_ipv6_cidr = "fd00::/126"        # /126 CIDR from fd00::/8 range (Transit Gateway only)

  # Authentication
  preshared_key = "your-preshared-key"   # 8-64 characters, alphanumeric + . + _
}
```

#### Dead Peer Detection (DPD) Settings

```hcl
tunnel1 = {
  dpd_timeout_action  = "clear"          # "clear", "none", or "restart"
  dpd_timeout_seconds = 30               # >= 30 seconds
}
```

#### Tunnel Lifecycle Control

```hcl
tunnel1 = {
  enable_tunnel_lifecycle_control = false  # Enable/disable tunnel endpoint lifecycle control
  startup_action                  = "add"  # "add" or "start"
}
```

#### IKE Configuration

```hcl
tunnel1 = {
  ike_versions = ["ikev1", "ikev2"]      # Supported IKE versions
}
```

#### Phase 1 IKE Configuration

```hcl
tunnel1 = {
  # Diffie-Hellman Groups
  phase1_dh_group_numbers = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]

  # Encryption Algorithms
  phase1_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]

  # Integrity Algorithms
  phase1_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]

  # Lifetime
  phase1_lifetime_seconds = 28800        # 900-28800 seconds
}
```

#### Phase 2 IKE Configuration

```hcl
tunnel1 = {
  # Diffie-Hellman Groups (includes group 2 and 5 for Phase 2)
  phase2_dh_group_numbers = [2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]

  # Encryption Algorithms
  phase2_encryption_algorithms = ["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"]

  # Integrity Algorithms
  phase2_integrity_algorithms = ["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"]

  # Lifetime
  phase2_lifetime_seconds = 3600         # 900-3600 seconds
}
```

#### Rekey Configuration

```hcl
tunnel1 = {
  rekey_fuzz_percentage     = 100        # 0-100%
  rekey_margin_time_seconds = 540        # 60 to half of phase2_lifetime_seconds
  replay_window_size        = 1024       # 64-2048 packets
}
```

#### Logging Configuration

```hcl
tunnel1 = {
  log_enabled           = true           # Enable CloudWatch logging
  log_group_arn         = null           # Custom log group ARN (optional)
  log_group_kms_arn     = null           # KMS key for log encryption (optional)
  log_output_format     = "json"         # "json" or "text"
  log_retention_in_days = 7              # Log retention period
}
```

## Complete Example

### High-Security Configuration

```hcl
site_to_site_vpn_config = {
  create = true

  customer_gateway = {
    bgp_asn     = 65000
    device_name = "Corporate Firewall"
    ip_address  = "203.0.113.12"
  }

  vpn_gateway = {
    vpc_id          = "vpc-12345678"
    route_table_ids = ["rtb-12345678", "rtb-87654321"]
  }

  vpn_connection = {
    static_routes_only       = true
    preshared_key_storage   = "SecretsManager"
    local_ipv4_network_cidr = "10.0.0.0/8"
    remote_ipv4_network_cidr = "172.16.0.0/12"

    tunnel_config = {
      tunnel1 = {
        inside_cidr                     = "169.254.1.0/30"
        dpd_timeout_action              = "restart"
        dpd_timeout_seconds             = 40
        enable_tunnel_lifecycle_control = true
        ike_versions                    = ["ikev2"]
        phase1_dh_group_numbers         = [19, 20, 21]  # Strong DH groups
        phase1_encryption_algorithms    = ["AES256-GCM-16"]
        phase1_integrity_algorithms     = ["SHA2-384"]
        phase1_lifetime_seconds         = 14400
        phase2_dh_group_numbers         = [19, 20, 21]
        phase2_encryption_algorithms    = ["AES256-GCM-16"]
        phase2_integrity_algorithms     = ["SHA2-384"]
        phase2_lifetime_seconds         = 1800
        rekey_fuzz_percentage           = 50
        rekey_margin_time_seconds       = 300
        replay_window_size              = 2048
        startup_action                  = "start"
        log_enabled                     = true
        log_output_format               = "json"
        log_retention_in_days           = 30
      }

      tunnel2 = {
        inside_cidr                     = "169.254.2.0/30"
        dpd_timeout_action              = "restart"
        dpd_timeout_seconds             = 40
        enable_tunnel_lifecycle_control = true
        ike_versions                    = ["ikev2"]
        phase1_dh_group_numbers         = [19, 20, 21]
        phase1_encryption_algorithms    = ["AES256-GCM-16"]
        phase1_integrity_algorithms     = ["SHA2-384"]
        phase1_lifetime_seconds         = 14400
        phase2_dh_group_numbers         = [19, 20, 21]
        phase2_encryption_algorithms    = ["AES256-GCM-16"]
        phase2_integrity_algorithms     = ["SHA2-384"]
        phase2_lifetime_seconds         = 1800
        rekey_fuzz_percentage           = 50
        rekey_margin_time_seconds       = 300
        replay_window_size              = 2048
        startup_action                  = "start"
        log_enabled                     = true
        log_output_format               = "json"
        log_retention_in_days           = 30
      }
    }

    routes = [
      { destination_cidr_block = "10.0.0.0/8" },
      { destination_cidr_block = "172.16.0.0/12" }
    ]
  }
}
```

### Transit Gateway with IPv6 Support

```hcl
site_to_site_vpn_config = {
  create = true

  customer_gateway = {
    bgp_asn    = 65000
    ip_address = "203.0.113.12"
  }

  vpn_gateway = {
    create = false  # Using Transit Gateway instead
  }

  vpn_connection = {
    transit_gateway_id       = "tgw-12345678"
    enable_acceleration      = true
    tunnel_inside_ip_version = "ipv6"
    local_ipv6_network_cidr  = "2001:db8::/32"
    remote_ipv6_network_cidr = "2001:db8:1::/48"

    tunnel_config = {
      tunnel1 = {
        inside_ipv6_cidr = "fd00::1:0/126"
        startup_action   = "start"
        log_enabled      = true
      }

      tunnel2 = {
        inside_ipv6_cidr = "fd00::2:0/126"
        startup_action   = "start"
        log_enabled      = true
      }
    }
  }
}
```

## Security Best Practices

### Recommended Security Settings

1. **Use Strong Encryption**: Prefer AES256-GCM-16 over AES128
2. **Strong Integrity**: Use SHA2-256 or higher (SHA2-384, SHA2-512)
3. **Strong DH Groups**: Use groups 19, 20, 21 for better security
4. **IKEv2 Only**: Disable IKEv1 if possible
5. **Secrets Manager**: Store pre-shared keys in AWS Secrets Manager
6. **Shorter Lifetimes**: Use shorter phase2 lifetimes for better security
7. **Enable Logging**: Always enable CloudWatch logging for monitoring

### Example Security-Focused Configuration

```hcl
tunnel1 = {
  ike_versions                    = ["ikev2"]                    # IKEv2 only
  phase1_dh_group_numbers         = [19, 20, 21]               # Strong DH groups
  phase1_encryption_algorithms    = ["AES256-GCM-16"]          # Strong encryption
  phase1_integrity_algorithms     = ["SHA2-384"]               # Strong integrity
  phase2_dh_group_numbers         = [19, 20, 21]               # Strong DH groups
  phase2_encryption_algorithms    = ["AES256-GCM-16"]          # Strong encryption
  phase2_integrity_algorithms     = ["SHA2-384"]               # Strong integrity
  phase2_lifetime_seconds         = 1800                       # Shorter lifetime
  dpd_timeout_action              = "restart"                  # Auto-restart on failure
  enable_tunnel_lifecycle_control = true                       # Better control
  startup_action                  = "start"                    # AWS initiates
  log_enabled                     = true                       # Enable monitoring
}
```

## Troubleshooting

### Common Configuration Issues

1. **DH Group Mismatch**: Ensure both sides support the same DH groups
2. **Lifetime Conflicts**: Phase1 lifetime should be longer than Phase2
3. **Rekey Timing**: rekey_margin_time_seconds must be ≤ half of phase2_lifetime_seconds
4. **IPv6 Requirements**: IPv6 features require Transit Gateway
5. **Acceleration**: VPN acceleration only works with Transit Gateway

### Validation Rules

- `phase1_lifetime_seconds`: 900-28800
- `phase2_lifetime_seconds`: 900-3600
- `dpd_timeout_seconds`: ≥30
- `rekey_margin_time_seconds`: 60 to (phase2_lifetime_seconds/2)
- `rekey_fuzz_percentage`: 0-100
- `replay_window_size`: 64-2048
- `inside_cidr`: /30 from 169.254.0.0/16
- `inside_ipv6_cidr`: /126 from fd00::/8

## Migration from Previous Version

If you're upgrading from a previous version, you'll need to update your configuration to include the new parameters. The module maintains backward compatibility by providing sensible defaults for all new parameters.

### Minimal Migration

Your existing configuration will continue to work, but you can now add any of the new parameters as needed:

```hcl
# Old configuration (still works)
tunnel1 = {
  inside_cidr   = null
  log_enabled   = true
}

# Enhanced configuration (new capabilities)
tunnel1 = {
  inside_cidr                  = null
  dpd_timeout_action           = "restart"  # New parameter
  phase1_encryption_algorithms = ["AES256-GCM-16"]  # Enhanced security
  startup_action               = "start"    # New parameter
  log_enabled                  = true
}
```
