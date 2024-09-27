################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "tags" {
  source  = "sourcefuse/arc-tags/aws"
  version = "1.2.3"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    Example  = "True"
    RepoPath = "github.com/sourcefuse/terraform-aws-refarch-vpn"
  }
}

################################################################################
## lookups
################################################################################
data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = var.vpc_name_override != null ? [var.vpc_name_override] : [
      "${var.namespace}-${var.environment}-vpc"
    ]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name = "tag:Name"
    values = length(var.private_subnet_names_override) > 0 ? var.private_subnet_names_override : [
      "${var.namespace}-${var.environment}-private-subnet-private-${var.region}a",
      "${var.namespace}-${var.environment}-private-subnet-private-${var.region}b"
    ]
  }
}

################################################################################
## certs
################################################################################
module "self_signed_cert_ca" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert.git?ref=1.3.0"

  attributes = ["self", "signed", "cert", "ca"]

  enabled = true

  namespace = var.namespace
  stage     = var.environment
  name      = "demo"

  secret_path_format = var.secret_path_format

  subject = {
    common_name  = "${var.namespace}-${var.environment}"
    organization = var.namespace
  }

  basic_constraints = {
    ca = true
  }

  allowed_uses = [
    "crl_signing",
    "cert_signing",
  ]

  certificate_backends = ["SSM"]
}

data "aws_ssm_parameter" "ca_key" {
  name = module.self_signed_cert_ca.certificate_key_path

  depends_on = [
    module.self_signed_cert_ca
  ]
}

module "self_signed_cert_root" {
  source = "git::https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert.git?ref=1.3.0"

  enabled = true

  attributes = ["self", "signed", "cert", "root"]

  namespace = var.namespace
  stage     = var.environment
  name      = "demo"

  secret_path_format = var.secret_path_format

  subject = {
    common_name  = "${var.namespace}-${var.environment}.arc-vpn-example.client"
    organization = var.namespace
  }

  basic_constraints = {
    ca = false
  }

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]

  certificate_backends = ["ACM", "SSM"]

  use_locally_signed = true

  certificate_chain = {
    cert_pem        = module.self_signed_cert_ca.certificate_pem,
    private_key_pem = join("", data.aws_ssm_parameter.ca_key[*].value)
  }
}


################################################################################
## vpn
################################################################################
module "vpn" {
  source = "../../"
  #version = "1.0.0" # pin the correct version

  name        = "poc-dev-client-vpn-example"
  namespace   = "poc"
  environment = "dev"
  vpc_id      = data.aws_vpc.this.id

  client_vpn_config = {

    client_cidr_block = cidrsubnet(data.aws_vpc.this.cidr_block, 6, 1)
    self_signed_cert_data = {
      create             = true
      secret_path_format = "/%s.%s"
      server_common_name = "${var.namespace}-${var.environment}.arc-vpn-example.client"
      organization_name  = var.namespace
      ca_pem             = module.self_signed_cert_ca.certificate_pem
      private_ca_key_pem = data.aws_ssm_parameter.ca_key.value
    }
    authentication_options = [
      {
        root_certificate_chain_arn = module.self_signed_cert_root.certificate_arn
        type                       = "certificate-authentication"
      }
    ]
    authorization_options = {
      "auth-1" = {
        target_network_cidr  = data.aws_vpc.this.cidr_block
        access_group_id      = null
        authorize_all_groups = true
      }
    }

    split_tunnel = true
    subnet_ids   = data.aws_subnets.private.ids
  }

  tags = module.tags.tags
}
