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
## Locals
################################################################################

locals {
  self_service_portal = var.self_service_portal_settings == "enabled"
  federated_authentication = var.client_authentication_type == "federated-authentication"
  self_service_federated_authentication = local.self_service_portal && var.client_authentication_type == "federated-authentication"
  certificatte_authentication = var.client_authentication_type == "certificatte-authentication"
  directory_service_authentication = var.client_authentication_type == "directory-service-authentication"

}

################################################################################
## Data lookups
################################################################################

data "aws_vpc" "this" {
  id = var.vpc_id
}

data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

################################################################################
## security groups
################################################################################

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.client_vpn_name}-sg"
  description = "Client VPN Security Group"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = var.ingress_rules
  egress_with_cidr_blocks = var.egress_rules

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_name
  }))
}

################################################################################
## VPN Gateway
################################################################################
resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_gateway_name
  }))
}

###############################################################################
## IAM Provider
###############################################################################

resource "aws_iam_saml_provider" "saml_provider" {
  count = var.iam_saml_provider_enabled == true ? 1 : 0

  name                   = var.iam_saml_provider_name
  saml_metadata_document = file(var.saml_metadata_document_name)

  tags = merge(var.tags, tomap({
    Name = var.iam_saml_provider_name
  }))
}

resource "aws_iam_saml_provider" "self_service_saml_provider" {
  count = var.self_service_portal_settings == "enabled" ? 1 : 0

  name                   = var.iam_self_service_saml_provider_name
  saml_metadata_document = file(var.saml_metadata_document_name)

  tags = merge(var.tags, tomap({
    Name = var.iam_self_service_saml_provider_name
  }))
}

###########################################################################
## Client VPN
###########################################################################

resource "aws_ec2_client_vpn_endpoint" "this" {
  vpc_id = var.vpc_id

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
    type              = var.client_authentication_type
    saml_provider_arn = local.federated_authentication ? try(var.saml_provider_arn, aws_iam_saml_provider.saml_provider[0].arn) : null
    self_service_saml_provider_arn = local.self_service_federated_authentication ? try(var.self_service_saml_provider_arn, aws_iam_saml_provider.self_service_saml_provider[0].arn) : null
    root_certificate_chain_arn = local.certificatte_authentication ? var.root_certificate_chain_arn : null
    active_directory_id = local.directory_service_authentication ? var.active_directory_id : null
  }

  ## security
  session_timeout_hours = var.session_timeout_hours
  server_certificate_arn = var.client_vpn_server_certificate_arn
  transport_protocol     = var.transport_protocol
  security_group_ids     = concat(module.security_group.security_group_id, var.client_vpn_additional_security_group_ids)

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_name
  }))
}

resource "aws_ec2_client_vpn_network_association" "this" {
  count                = length(data.aws_subnets.this.ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id            = data.aws_subnets.this.ids[count.index]
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = data.aws_vpc.this.cidr_block
  authorize_all_groups   = var.authorize_all_groups_for_client_vpn
}
