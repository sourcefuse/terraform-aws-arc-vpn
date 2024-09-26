################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.4, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0, < 6.0"
    }
  }
}

################################################################################
## Client VPN
################################################################################

module "client_vpn" {
  source = "./modules/client-vpn"

  name                   = var.client_vpn_config.name
  vpc_id                 = var.vpc_id
  client_cidr_block      = var.client_vpn_config.client_cidr_block
  self_signed_cert_data  = var.client_vpn_config.self_signed_cert_data
  authentication_options = var.client_vpn_config.authentication_options
  authorization_options  = var.client_vpn_config.authorization_options
  log_options            = var.client_vpn_config.log_options
  security_group_data    = var.client_vpn_config.security_group_data

  # SAML provider mappings
  iam_saml_provider_enabled      = var.client_vpn_config.iam_saml_provider_enabled
  iam_saml_provider_name         = var.client_vpn_config.iam_saml_provider_name
  saml_metadata_document_content = var.client_vpn_config.saml_metadata_document_content

  # VPN endpoint configurations
  split_tunnel        = var.client_vpn_config.split_tunnel
  self_service_portal = var.client_vpn_config.self_service_portal
  dns_servers         = var.client_vpn_config.dns_servers

  # Server certificate and transport settings
  client_server_certificate_arn    = var.client_vpn_config.client_server_certificate_arn
  client_server_transport_protocol = var.client_vpn_config.client_server_transport_protocol

  # Network associations
  subnet_ids = var.client_vpn_config.subnet_ids

  tags = var.tags
}
