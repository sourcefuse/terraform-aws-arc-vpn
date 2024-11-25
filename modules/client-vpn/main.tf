
################################################################################
## security groups
################################################################################
resource "aws_security_group" "vpn" {
  name        = "${var.name}-sg"
  description = "VPN Security Group configuration"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.security_group_data.ingress_rules

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
    for_each = var.security_group_data.egress_rules

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
    Name = "${var.name}-sg"
  }))

  lifecycle {
    create_before_destroy = true
  }
}

################################################################################
## certs
################################################################################
# module "self_signed_cert" {
#   source = "git::https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert.git?ref=1.3.0"
#   count  = var.self_signed_cert_data.create == true ? 1 : 0

#   attributes         = ["self", "signed", "cert", "server"]
#   secret_path_format = var.self_signed_cert_data.secret_path_format

#   name = var.name


#   subject = {
#     common_name  = var.self_signed_cert_data.server_common_name
#     organization = var.self_signed_cert_data.organization_name
#   }
#   basic_constraints = {
#     ca = false
#   }

#   allowed_uses = var.self_signed_cert_data.allowed_uses

#   certificate_backends = ["ACM", "SSM"]

#   use_locally_signed = true

#   certificate_chain = {
#     cert_pem        = var.self_signed_cert_data.ca_pem
#     private_key_pem = var.self_signed_cert_data.private_ca_key_pem
#   }

#   tags = var.tags
# }


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
  client_cidr_block   = var.client_cidr_block
  split_tunnel        = var.split_tunnel
  self_service_portal = var.self_service_portal
  dns_servers         = var.dns_servers

  ## logging
  connection_log_options {
    enabled               = var.log_options.enabled
    cloudwatch_log_stream = var.log_options.cloudwatch_log_stream
    cloudwatch_log_group  = var.log_options.cloudwatch_log_group
  }

  ## authentication
  dynamic "authentication_options" {
    for_each = var.authentication_options
    content {
      active_directory_id            = authentication_options.value.active_directory_id
      root_certificate_chain_arn     = authentication_options.value.root_certificate_chain_arn
      saml_provider_arn              = var.iam_saml_provider_enabled == true ? one(aws_iam_saml_provider.this[*].arn) : authentication_options.value.saml_provider_arn
      self_service_saml_provider_arn = authentication_options.value.self_service_saml_provider_arn
      type                           = authentication_options.value.type
    }
  }

  ## security
  server_certificate_arn = var.use_self_signed_cert ? tls_self_signed_cert.self_signed_cert[0].cert_pem : var.client_server_certificate_arn
  transport_protocol     = var.client_server_transport_protocol
  security_group_ids     = concat([aws_security_group.vpn.id], var.security_group_data.additional_security_group_ids)

  tags = merge(var.tags, tomap({
    Name = var.name
  }))
}


## associations
resource "aws_ec2_client_vpn_network_association" "this" {
  for_each = toset(var.subnet_ids)

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  subnet_id              = each.value
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  for_each = var.authorization_options

  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = each.value.target_network_cidr
  access_group_id        = each.value.access_group_id
  authorize_all_groups   = each.value.authorize_all_groups
}
