################################################################################
## defaults
################################################################################
terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
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
    RepoPath = "github.com/sourcefuse/terraform-aws-arc-vpn"
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

## Create CA Certificate

module "ca" {
  source = "../../modules/certificate"
  name   = "poc-dev-client-vpn-ca"
  type   = "ca"
  subject = {
    common_name  = "ca.test.vpn"
    organization = "vpn-test"
  }
  environment = "dev"
  namespace   = "arc"

  import_to_acm    = true
  store_in_ssm     = true
  store_it_locally = false
}

## Create Root certificate
module "root" {
  source             = "../../modules/certificate"
  name               = "poc-dev-client-vpn-root"
  type               = "root"
  ca_cert_pem        = module.ca.ca_cert_pem
  ca_private_key_pem = module.ca.private_key_pem
  subject = {
    common_name  = "root.test.vpn"
    organization = "vpn-test"
  }
  environment = "dev"
  namespace   = "arc"

  import_to_acm    = true
  store_in_ssm     = true
  store_it_locally = false
}


################################################################################
## vpn
################################################################################
module "vpn" {
  source = "../../"
  #version = "1.0.0" # pin the correct version

  name        = "poc-dev-client-vpn-example-1"
  namespace   = "arc"
  environment = "dev"
  vpc_id      = data.aws_vpc.this.id

  client_vpn_config = {
    create            = true
    client_cidr_block = cidrsubnet(data.aws_vpc.this.cidr_block, 6, 1)
    server_certificate_data = {
      create             = true
      common_name        = "${var.namespace}-${var.environment}.server.arc-vpn"
      organization       = var.namespace
      ca_cert_pem        = module.ca.ca_cert_pem
      ca_private_key_pem = module.ca.private_key_pem
    }
    authentication_options = [
      {
        root_certificate_chain_arn = module.root.certificate_arn
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
