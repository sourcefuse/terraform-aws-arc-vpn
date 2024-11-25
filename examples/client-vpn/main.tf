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
# module "self_signed_cert_ca" {
#   source = "git::https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert.git?ref=1.3.0"

#   attributes = ["self", "signed", "cert", "ca"]

#   enabled = true

#   namespace = var.namespace
#   stage     = var.environment
#   name      = "demo"

#   secret_path_format = var.secret_path_format

#   subject = {
#     common_name  = "${var.namespace}-${var.environment}"
#     organization = var.namespace
#   }

#   basic_constraints = {
#     ca = true
#   }

#   allowed_uses = [
#     "crl_signing",
#     "cert_signing",
#   ]

#   certificate_backends = ["SSM"]
# }
module "self_signed_cert_ca" {
  source = "../../modules/acm"

  # Variables for private key generation
  generate_private_key     = true
  private_key              = ""
  private_key_algorithm    = "RSA"
  rsa_bits                 = 2048
  ecdsa_curve              = "P256"

  # Variables for certificate generation
  create_certificate_request = false
  use_self_signed_cert       = true
  certificate_validity_hours = 8760 # 1 year
  is_ca                      = true
  set_subject_key_id         = true
  set_authority_key_id       = true
  allowed_uses               = ["key_cert_sign", "crl_sign"]

  # Certificate subject details
  subject_common_name         = "arc-test-refactor-vpn.com"
  subject_organization        = "Example Org"
  subject_organizational_unit = "Example Unit"
  subject_locality            = "Example City"
  subject_province            = "Example State"
  subject_country             = "US"

  # Additional SAN entries
  additional_dns_names    = []
  additional_ip_addresses = []
  additional_uris         = []

  # SSM parameter configurations
  secret_path_format         = "%s/%s"
  certificate_name_prefix    = "vpn-ca-cert-arc"
  private_key_name_prefix    = "vpn-ca-key-arc"
  tags                       = {
    Environment = "re-factor-arc"
    Project     = "VPN"
  }
}


data "aws_ssm_parameter" "ca_key" {
  name = module.self_signed_cert_ca.certificate_key_path

  depends_on = [
    module.self_signed_cert_ca
  ]
}

module "self_signed_cert_root" {
  source = "../../modules/acm"

  # Generate Private Key Configuration
  generate_private_key  = true
  private_key           = ""
  private_key_algorithm = "RSA"
  rsa_bits              = 2048
  ecdsa_curve           = null # Not applicable for RSA

  # Certificate Request and Self-Signed Certificate Configurations
  create_certificate_request = false
  use_self_signed_cert       = true
  certificate_validity_hours = 8760  # Valid for 1 year
  is_ca                      = true  # Marks as a Certificate Authority
  set_subject_key_id         = true  # Enables subject key ID
  set_authority_key_id       = true  # Enables authority key ID

  # Allowed uses for the certificate
  allowed_uses = [
    "key_cert_sign",  # Allow signing other certificates
    "crl_sign"        # Allow signing certificate revocation lists
  ]

  # Subject details for the Root Certificate
  subject_common_name         = "arc-root-cert.example.com"
  subject_organization        = "Example Organization"
  subject_organizational_unit = "Root CA"
  subject_locality            = "Example City"
  subject_province            = "Example State"
  subject_country             = "US"

  # Additional Subject Alternative Names (SANs)
  additional_dns_names    = ["root-ca.example.com"]
  additional_ip_addresses = []
  additional_uris         = []

  # SSM Parameter Storage Configuration
  secret_path_format      = "%s/%s"
  certificate_name_prefix = "root-ca-cert"
  private_key_name_prefix = "root-ca-key"

  # Tags for resources
  tags = {
    Environment = "production"
    Project     = "Root-CA"
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
