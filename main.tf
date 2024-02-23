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
## security groups
################################################################################
resource "aws_security_group" "vpn" {
  name        = "${var.client_vpn_name}-sg"
  description = "VPN Security Group configuration"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.client_vpn_ingress_rules

    content {
      description      = ingress.value.description
      from_port        = ingress.value.from_port
      to_port          = ingress.value.to_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_blocks
      security_groups  = ingress.value.security_group_ids
      ipv6_cidr_blocks = ingress.value.ipv6_cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.client_vpn_egress_rules

    content {
      description      = egress.value.description
      from_port        = egress.value.from_port
      to_port          = egress.value.to_port
      protocol         = egress.value.protocol
      cidr_blocks      = egress.value.cidr_blocks
      security_groups  = egress.value.security_group_ids
      ipv6_cidr_blocks = egress.value.ipv6_cidr_blocks
    }
  }

  tags = merge(var.tags, tomap({
    Name = "${var.client_vpn_name}-sg"
  }))

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
## certs
################################################################################
module "self_signed_cert" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert.git?ref=1.3.0"
  count  = var.create_self_signed_server_cert == true ? 1 : 0

  attributes         = ["self", "signed", "cert", "server"]
  secret_path_format = var.self_signed_server_cert_secret_path_format

   name = var.client_vpn_name


  subject = {
    common_name  = var.self_signed_server_cert_server_common_name
    organization = var.self_signed_server_cert_organization_name
  }
  basic_constraints = {
    ca = false
  }

  allowed_uses = var.self_signed_server_cert_allowed_uses

  certificate_backends = ["ACM", "SSM"]

  use_locally_signed = true

  certificate_chain = {
    cert_pem        = var.self_signed_server_cert_ca_pem
    private_key_pem = var.self_signed_server_cert_private_ca_key_pem
  }

  tags = var.tags
}

################################################################################
## vpn
################################################################################
resource "aws_vpn_gateway" "this" {
  count = var.create_vpn_gateway ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_gateway_name
  }))
}

resource "aws_iam_saml_provider" "this" {
  count = var.iam_saml_provider_enabled == true ? 1 : 0

  name                   = var.iam_saml_provider_name
  saml_metadata_document = var.saml_metadata_document_content

  tags = merge(var.tags, tomap({
    Name = var.iam_saml_provider_name
  }))
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  vpc_id = var.vpc_id

  ## network
  client_cidr_block   = var.client_cidr
  split_tunnel        = var.client_vpn_split_tunnel
  self_service_portal = var.client_vpn_self_service_portal
  dns_servers         = var.dns_servers

  ## logging
  connection_log_options {
    enabled               = var.client_vpn_log_options.enabled
    cloudwatch_log_stream = var.client_vpn_log_options.cloudwatch_log_stream
    cloudwatch_log_group  = var.client_vpn_log_options.cloudwatch_log_group
  }

  ## authentication
  authentication_options {
    active_directory_id            = var.authentication_options_active_directory_id
    root_certificate_chain_arn     = var.authentication_options_root_certificate_chain_arn
    saml_provider_arn              = var.iam_saml_provider_enabled == true ? one(aws_iam_saml_provider.this[*].arn) : var.authentication_options_saml_provider_arn
    self_service_saml_provider_arn = var.authentication_options_self_service_saml_provider_arn
    type                           = var.authentication_options_type
  }

  ## security
  server_certificate_arn = length(module.self_signed_cert) > 0 ? one(module.self_signed_cert[*].certificate_arn) : var.client_server_certificate_arn
  transport_protocol     = var.client_server_transport_protocol
  security_group_ids     = concat([aws_security_group.vpn.id], var.client_vpn_additional_security_group_ids)

  depends_on = [
    module.self_signed_cert
  ]

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_name
  }))
}

## associations
resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(var.client_vpn_subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = var.client_vpn_target_network_cidr
  access_group_id        = var.client_vpn_access_group_id
  authorize_all_groups   = var.client_vpn_authorize_all_groups
}
