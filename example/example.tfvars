tags = {
  Environment = "dev"
  Project = "test"
}
vpc_id = "vpc-01973445970d86836"
environment = "poc"
namespace   = "arc"
region      = "us-east-1"
client_vpn_cidr = "10.1.5.0/22"
client_vpn_server_certificate_arn = "arn:aws:acm:us-east-1:682732873102:certificate/ecee89b8-7dfc-4b5d-bfa4-776290cc4f92"
root_certificate_chain_arn = "arn:aws:acm:us-east-1:682732873102:certificate/ecee89b8-7dfc-4b5d-bfa4-776290cc4f92"
self_service_portal_settings = "enabled"
transport_protocol = "tcp"

ingress_rules = [
  {
    to_port = 443
    from_port = 443
    protocol = "tcp"
    cidr_blocks = "0.0.0.0/0"
    description = "test rules"
  },
]
egress_rules =[
  {
    to_port = 0
    from_port = 0
    protocol = "-1"
    cidr_blocks = "0.0.0.0/0"
    description = "test rules"
  },
]
