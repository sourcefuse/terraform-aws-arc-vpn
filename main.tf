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
## vpn
################################################################################
resource "aws_vpn_gateway" "default" {
  vpc_id = data.aws_vpc.vpc.id

  tags = merge(module.tags.tags, tomap({
    Name = "${var.namespace}-${var.environment}-${var.client_vpn_gateway_name}"
  }))
}

resource "aws_iam_saml_provider" "default" {

  name                   = var.iam_saml_provider_name
  saml_metadata_document = var.saml_metadata_document_content
}

resource "aws_ec2_client_vpn_endpoint" "default" {
  vpc_id = data.aws_vpc.vpc.id

  ## network
  client_cidr_block   = var.client_cidr
  split_tunnel        = var.client_vpn_split_tunnel
  self_service_portal = "enabled"
  dns_servers         = var.dns_servers

  ## logging
  connection_log_options {
    enabled               = true
    cloudwatch_log_stream = var.cloudwatch_log_stream_name
    cloudwatch_log_group  = var.cloudwatch_log_group_name
  }

  ## authentication
  authentication_options {
    type              = "federated-authentication"        ## other options are "certificate-authentication" or "directory-service-authentication"
    saml_provider_arn = aws_iam_saml_provider.default.arn ## for federated-authentication
    # root_certificate_chain_arn = var.root_certificate_chain_arn    ## for certificate-authentication
    # active_directory_id = var.active_directory_id              ## for directory-service-authentication
  }

  ## security
  server_certificate_arn = data.aws_acm_certificate.cert.arn
  transport_protocol     = var.transport_protocol
  security_group_ids     = data.aws_security_groups.security_groups.ids

  tags = {
    Name = "${var.namespace}-${var.environment}-${var.client_vpn_name}"
  }
}
