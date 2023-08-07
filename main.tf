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
  vpc_id      = var.vpc_id // TODO - add `var.vpc_id` to variables.tf

  // TODO - make this dynamic and able to pass in different rules downstream.
  ingress {
    description      = "TLS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = []
    ipv6_cidr_blocks = []
  }

  // TODO - make this dynamic and able to pass in different rules downstream
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(var.tags, tomap({
    Name = "${var.client_vpn_name}-sg"
  }))
}

################################################################################
## vpn
################################################################################
resource "aws_vpn_gateway" "this" {
  vpc_id = var.vpc_id // TODO - add `var.vpc_id` to variables.tf

  // TODO - `var.tags` to variables.tf
  tags = merge(var.tags, tomap({
    Name = var.client_vpn_gateway_name
  }))
}

resource "aws_iam_saml_provider" "this" {
  // TODO - `var.iam_saml_provider_enabled` to variables.tf and assign the default to false
  count = var.iam_saml_provider_enabled == true ? 1 : 0

  name                   = var.iam_saml_provider_name
  saml_metadata_document = var.saml_metadata_document_content

  tags = merge(var.tags, tomap({
    Name = var.iam_saml_provider_name
  }))
}

resource "aws_ec2_client_vpn_endpoint" "this" {
  vpc_id = var.vpc_id // TODO - add `var.vpc_id` to variables.tf

  ## network
  client_cidr_block   = var.client_cidr
  split_tunnel        = var.client_vpn_split_tunnel
  self_service_portal = "enabled" // TODO - this needs to be a variable
  dns_servers         = var.dns_servers

  ## logging
  connection_log_options {
    enabled               = true // TODO - this needs to be a variable
    cloudwatch_log_stream = var.cloudwatch_log_stream_name
    cloudwatch_log_group  = var.cloudwatch_log_group_name
  }

  ## authentication
  // TODO - this section needs to be dynamic since it's dependent on aws_iam_saml_provider.this which may not always be created
  authentication_options {
    type              = "federated-authentication"     // TODO - make this a variable with "federated-authentication" as the default. list the additional options in the description: "certificate-authentication" or "directory-service-authentication"
    saml_provider_arn = aws_iam_saml_provider.this.arn ## for federated-authentication  // TODO - if there is a different type assigned, this wont work. this probably will need a try() function
  }

  ## security
  server_certificate_arn = var.client_server_certificate_arn // TODO - this needs to be a variable and passed in downstream
  transport_protocol     = var.transport_protocol
  security_group_ids     = concat(aws_security_group.vpn.id, var.client_vpn_additional_security_group_ids) // TODO - `var.client_vpn_additional_security_group_ids` needs to be a variable and have a default of []

  tags = merge(var.tags, tomap({
    Name = var.client_vpn_name
  }))
}
