locals {
  prefix                   = "${var.namespace}-${var.environment}"
  vpn_routes               = nonsensitive(var.vpn_connection_config.routes)
  vpn_gateway_route_tables = nonsensitive(var.vpn_gateway_config.route_table_ids)
}
