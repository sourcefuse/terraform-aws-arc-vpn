
vpc_name                          = "arc-poc-vpc"
client_vpn_cidr                   = "10.12.4.0/22"
self_service_portal_settings      = "disabled"
transport_protocol                = "tcp"
tags = {
  Environment = "dev"
  Project     = "test"
}
ingress_rules = [
  {
    to_port     = 443
    from_port   = 443
    protocol    = "tcp"
    cidr_blocks = "0.0.0.0/0"
    description = "test rules"
  },
]
egress_rules = [
  {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
    description = "test rules"
  },
]
