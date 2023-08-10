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
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-tags.git?ref=1.2.1"

  environment = var.environment
  project     = var.project_name

  extra_tags = {
    Example = "True"
  }
}

################################################################################
## lookups
################################################################################
data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = try([
      "${var.namespace}-${var.environment}-vpc"
    ], [var.vpc_name])
  }
}

/*data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Name"
    values = try([
      "${var.namespace}-${var.environment}-private-subnet-private-${var.region}a",
      "${var.namespace}-${var.environment}-private-subnet-private-${var.region}b"
    ] ,var.private_subnet_names)
  }
}

data "aws_subnets" "private" {
  filter {
    name = "tag:Name"

    values = var.private_subnet_names
  }
}

data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}*/

################################################################################
## vpn
################################################################################
module "vpn" {
  source = "../"

  vpc_id = data.aws_vpc.this.id

  client_cidr             = cidrsubnet(data.aws_vpc.this.cidr_block, 12, 1)
  client_vpn_gateway_name = "${var.namespace}-${var.environment}-vpn-gateway"

  ## self signed certificate
  create_self_signed_server_cert = true
  self_signed_server_cert_name   = "${var.namespace}-${var.environment}-server-cert"
  self_signed_server_cert_allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
  ]
  self_signed_server_cert_subject = {
    common_name         = "arc-example.fake"
    organization        = "SourceFuse ARC Examples"
    organizational_unit = "Engineering"
  }
  self_signed_server_cert_subject_alt_names = {
    dns_names = [
      "arc-example.fake",
      "poc.arc-example.fake"
    ]
  }

  tags = module.tags.tags
}
