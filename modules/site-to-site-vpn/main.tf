# Create the Customer Gateway
resource "aws_customer_gateway" "this" {
  bgp_asn         = var.customer_gateway_config.bgp_asn
  certificate_arn = var.customer_gateway_config.certificate_arn
  device_name     = var.customer_gateway_config.device_name
  ip_address      = var.customer_gateway_config.ip_address
  type            = var.customer_gateway_config.type
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Create the Virtual Private Gateway (VGW)
resource "aws_vpn_gateway" "this" {
  count = var.vpn_gateway_config.create ? 1 : 0

  vpc_id            = var.vpn_gateway_config.vpc_id
  amazon_side_asn   = var.vpn_gateway_config.amazon_side_asn
  availability_zone = var.vpn_gateway_config.availability_zone
  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Main VPN connection resource
resource "aws_vpn_connection" "this" {
  customer_gateway_id                     = aws_customer_gateway.this.id
  type                                    = aws_customer_gateway.this.type
  vpn_gateway_id                          = var.vpn_gateway_config.create ? aws_vpn_gateway.this[0].id : var.vpn_connection_config.vpn_gateway_id
  transit_gateway_id                      = var.vpn_connection_config.transit_gateway_id
  static_routes_only                      = var.vpn_connection_config.static_routes_only
  enable_acceleration                     = var.vpn_connection_config.enable_acceleration
  local_ipv4_network_cidr                 = var.vpn_connection_config.local_ipv4_network_cidr
  local_ipv6_network_cidr                 = var.vpn_connection_config.local_ipv6_network_cidr
  outside_ip_address_type                 = var.vpn_connection_config.outside_ip_address_type
  remote_ipv4_network_cidr                = var.vpn_connection_config.remote_ipv4_network_cidr
  remote_ipv6_network_cidr                = var.vpn_connection_config.remote_ipv6_network_cidr
  transport_transit_gateway_attachment_id = var.vpn_connection_config.transport_transit_gateway_attachment_id
  tunnel_inside_ip_version                = var.vpn_connection_config.tunnel_inside_ip_version

  # Tunnel 1 Configuration
  tunnel1_inside_cidr                     = var.vpn_connection_config.tunnel_config.tunnel1.inside_cidr
  tunnel1_inside_ipv6_cidr                = var.vpn_connection_config.tunnel_config.tunnel1.inside_ipv6_cidr
  tunnel1_preshared_key                   = var.vpn_connection_config.tunnel_config.tunnel1.preshared_key
  tunnel1_dpd_timeout_action              = var.vpn_connection_config.tunnel_config.tunnel1.dpd_timeout_action
  tunnel1_dpd_timeout_seconds             = var.vpn_connection_config.tunnel_config.tunnel1.dpd_timeout_seconds
  tunnel1_enable_tunnel_lifecycle_control = var.vpn_connection_config.tunnel_config.tunnel1.enable_tunnel_lifecycle_control
  tunnel1_ike_versions                    = var.vpn_connection_config.tunnel_config.tunnel1.ike_versions
  tunnel1_phase1_dh_group_numbers         = var.vpn_connection_config.tunnel_config.tunnel1.phase1_dh_group_numbers
  tunnel1_phase1_encryption_algorithms    = var.vpn_connection_config.tunnel_config.tunnel1.phase1_encryption_algorithms
  tunnel1_phase1_integrity_algorithms     = var.vpn_connection_config.tunnel_config.tunnel1.phase1_integrity_algorithms
  tunnel1_phase1_lifetime_seconds         = var.vpn_connection_config.tunnel_config.tunnel1.phase1_lifetime_seconds
  tunnel1_phase2_dh_group_numbers         = var.vpn_connection_config.tunnel_config.tunnel1.phase2_dh_group_numbers
  tunnel1_phase2_encryption_algorithms    = var.vpn_connection_config.tunnel_config.tunnel1.phase2_encryption_algorithms
  tunnel1_phase2_integrity_algorithms     = var.vpn_connection_config.tunnel_config.tunnel1.phase2_integrity_algorithms
  tunnel1_phase2_lifetime_seconds         = var.vpn_connection_config.tunnel_config.tunnel1.phase2_lifetime_seconds
  tunnel1_rekey_fuzz_percentage           = var.vpn_connection_config.tunnel_config.tunnel1.rekey_fuzz_percentage
  tunnel1_rekey_margin_time_seconds       = var.vpn_connection_config.tunnel_config.tunnel1.rekey_margin_time_seconds
  tunnel1_replay_window_size              = var.vpn_connection_config.tunnel_config.tunnel1.replay_window_size
  tunnel1_startup_action                  = var.vpn_connection_config.tunnel_config.tunnel1.startup_action

  # Tunnel 2 Configuration
  tunnel2_inside_cidr                     = var.vpn_connection_config.tunnel_config.tunnel2.inside_cidr
  tunnel2_inside_ipv6_cidr                = var.vpn_connection_config.tunnel_config.tunnel2.inside_ipv6_cidr
  tunnel2_preshared_key                   = var.vpn_connection_config.tunnel_config.tunnel2.preshared_key
  tunnel2_dpd_timeout_action              = var.vpn_connection_config.tunnel_config.tunnel2.dpd_timeout_action
  tunnel2_dpd_timeout_seconds             = var.vpn_connection_config.tunnel_config.tunnel2.dpd_timeout_seconds
  tunnel2_enable_tunnel_lifecycle_control = var.vpn_connection_config.tunnel_config.tunnel2.enable_tunnel_lifecycle_control
  tunnel2_ike_versions                    = var.vpn_connection_config.tunnel_config.tunnel2.ike_versions
  tunnel2_phase1_dh_group_numbers         = var.vpn_connection_config.tunnel_config.tunnel2.phase1_dh_group_numbers
  tunnel2_phase1_encryption_algorithms    = var.vpn_connection_config.tunnel_config.tunnel2.phase1_encryption_algorithms
  tunnel2_phase1_integrity_algorithms     = var.vpn_connection_config.tunnel_config.tunnel2.phase1_integrity_algorithms
  tunnel2_phase1_lifetime_seconds         = var.vpn_connection_config.tunnel_config.tunnel2.phase1_lifetime_seconds
  tunnel2_phase2_dh_group_numbers         = var.vpn_connection_config.tunnel_config.tunnel2.phase2_dh_group_numbers
  tunnel2_phase2_encryption_algorithms    = var.vpn_connection_config.tunnel_config.tunnel2.phase2_encryption_algorithms
  tunnel2_phase2_integrity_algorithms     = var.vpn_connection_config.tunnel_config.tunnel2.phase2_integrity_algorithms
  tunnel2_phase2_lifetime_seconds         = var.vpn_connection_config.tunnel_config.tunnel2.phase2_lifetime_seconds
  tunnel2_rekey_fuzz_percentage           = var.vpn_connection_config.tunnel_config.tunnel2.rekey_fuzz_percentage
  tunnel2_rekey_margin_time_seconds       = var.vpn_connection_config.tunnel_config.tunnel2.rekey_margin_time_seconds
  tunnel2_replay_window_size              = var.vpn_connection_config.tunnel_config.tunnel2.replay_window_size
  tunnel2_startup_action                  = var.vpn_connection_config.tunnel_config.tunnel2.startup_action

  # VPN Logging configuration
  dynamic "tunnel1_log_options" {
    for_each = var.vpn_connection_config.tunnel_config.tunnel1.log_enabled ? [1] : []
    content {
      cloudwatch_log_options {
        log_group_arn     = var.vpn_connection_config.tunnel_config.tunnel1.log_group_arn == null ? aws_cloudwatch_log_group.tunnel1[0].arn : var.vpn_connection_config.tunnel_config.tunnel1.log_group_arn
        log_output_format = var.vpn_connection_config.tunnel_config.tunnel1.log_output_format
        log_enabled       = var.vpn_connection_config.tunnel_config.tunnel1.log_enabled
      }
    }
  }

  dynamic "tunnel2_log_options" {
    for_each = var.vpn_connection_config.tunnel_config.tunnel2.log_enabled ? [1] : []
    content {
      cloudwatch_log_options {
        log_group_arn     = var.vpn_connection_config.tunnel_config.tunnel2.log_group_arn == null ? aws_cloudwatch_log_group.tunnel2[0].arn : var.vpn_connection_config.tunnel_config.tunnel2.log_group_arn
        log_output_format = var.vpn_connection_config.tunnel_config.tunnel2.log_output_format
        log_enabled       = var.vpn_connection_config.tunnel_config.tunnel2.log_enabled
      }
    }
  }

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# VPN connection routes (if static routes are enabled)
resource "aws_vpn_connection_route" "this" {
  for_each = { for obj in local.vpn_routes : obj.destination_cidr_block => obj }

  destination_cidr_block = each.key
  vpn_connection_id      = aws_vpn_connection.this.id
}

# # VPN CloudWatch Logs
resource "aws_cloudwatch_log_group" "tunnel1" {
  count             = var.vpn_connection_config.tunnel_config.tunnel1.log_enabled ? 1 : 0
  name              = "${local.prefix}-${var.name}-tunnel1"
  retention_in_days = var.vpn_connection_config.tunnel_config.tunnel1.log_retention_in_days
  kms_key_id        = var.vpn_connection_config.tunnel_config.tunnel2.log_group_kms_arn
}

resource "aws_cloudwatch_log_group" "tunnel2" {
  count             = var.vpn_connection_config.tunnel_config.tunnel2.log_enabled ? 1 : 0
  name              = "${local.prefix}-${var.name}-tunnel2"
  retention_in_days = var.vpn_connection_config.tunnel_config.tunnel2.log_retention_in_days
  kms_key_id        = var.vpn_connection_config.tunnel_config.tunnel2.log_group_kms_arn
}

resource "aws_vpn_gateway_route_propagation" "this" {
  for_each = toset(local.vpn_gateway_route_tables)

  vpn_gateway_id = aws_vpn_gateway.this[0].id
  route_table_id = each.value
}
