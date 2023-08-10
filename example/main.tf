################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      version = ">= 4.0"
      source  = "hashicorp/aws"
    }
  }
}

################################################################################
## Data lookups
################################################################################
data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}

################################################################################
## self-signed tls certificates
################################################################################

resource "aws_route53_zone" "this" {
  name = var.route_53_zone
}

module "acm_request_server_certificate" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.15.1"

  domain_name                       = "${var.route_53_zone}-1"
  process_domain_validation_options = true
  ttl                               = "300"
  subject_alternative_names         = ["*.'${var.route_53_zone}-1'"]
  depends_on                        = [aws_route53_zone.this]
}

module "acm_request_root_certificate" {
  source  = "cloudposse/acm-request-certificate/aws"
  version = "0.15.1"

  domain_name                       = "${var.route_53_zone}-2"
  process_domain_validation_options = true
  ttl                               = "300"
  subject_alternative_names         = ["*.'${var.route_53_zone}-2'"]
  depends_on                        = [aws_route53_zone.this]
}

################################################################################
## security groups
################################################################################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.client_vpn_name}-sg"
  description = "Client VPN Security Group"
  vpc_id      = data.aws_vpc.this.id

  ingress_with_cidr_blocks = var.ingress_rules
  egress_with_cidr_blocks  = var.egress_rules

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_name
  }))
}

################################################################################
## VPN Gateway
################################################################################
resource "aws_vpn_gateway" "this" {
  vpc_id = data.aws_vpc.this.id

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_gateway_name
  }))
}

###########################################################################
## Client VPN
###########################################################################

resource "aws_ec2_client_vpn_endpoint" "this" {
  depends_on = [module.acm_request_root_certificate, module.acm_request_server_certificate]
  vpc_id     = data.aws_vpc.this.id

  ## network
  client_cidr_block   = var.client_vpn_cidr
  split_tunnel        = var.client_vpn_split_tunnel
  self_service_portal = var.self_service_portal_settings
  dns_servers         = var.dns_servers

  ## logging
  connection_log_options {
    enabled               = var.connection_log_enabled
    cloudwatch_log_stream = var.cloudwatch_log_stream_name
    cloudwatch_log_group  = var.cloudwatch_log_group_name
  }

  ## authentication
  authentication_options {
    type                           = var.client_authentication_type
    saml_provider_arn              = var.saml_provider_arn
    self_service_saml_provider_arn = var.self_service_saml_provider_arn
    root_certificate_chain_arn     = module.acm_request_root_certificate.arn
    active_directory_id            = var.active_directory_id
  }

  ## security
  session_timeout_hours  = var.session_timeout_hours
  server_certificate_arn = module.acm_request_server_certificate.arn
  transport_protocol     = var.transport_protocol
  security_group_ids     = concat(tolist([module.security_group.security_group_id]), var.client_vpn_additional_security_group_ids)

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_name
  }))
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(data.aws_subnets.this.ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = data.aws_vpc.this.cidr_block
  authorize_all_groups   = var.authorize_all_groups_for_client_vpn
}
