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
    RepoPath = "github.com/sourcefuse/terraform-aws-refarch-vpn"
  }
}

################################################################################
## lookups
################################################################################
data "aws_vpc" "this" {
  filter {
    name = "tag:Name"
    values = [
      "arc-poc-vpc"
    ]
  }
}

# Fetch all route tables in the VPC
data "aws_route_tables" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

################################################################################
## Site to Site VPN
################################################################################
module "vpn" {
  source = "../../"
  #version = "1.0.0" # pin the correct version

  name        = "${var.namespace}-${var.environment}-site-to-site-vpn-example"
  namespace   = var.namespace
  environment = var.environment
  vpc_id      = data.aws_vpc.this.id

  site_to_site_vpn_config = {
    create = true
    customer_gateway = {
      bgp_asn     = 65000                          # The Border Gateway Protocol (BGP) Autonomous System Number (ASN) Value must be in 1 - 4294967294 range.
      device_name = "Demo customer gateway device" # A name for the customer gateway device.
      ip_address  = "52.90.63.124"                 # The IP address of the customer gateway
    }

    vpn_gateway = {
      vpc_id          = data.aws_vpc.this.id
      route_table_ids = data.aws_route_tables.private.ids
    }

    vpn_connection = {
      static_routes_only       = true
      local_ipv4_network_cidr  = "10.3.0.0/16"
      remote_ipv4_network_cidr = "10.0.0.0/16"

      tunnel_config = {
        tunnel1 = {
          inside_cidr           = null
          log_enabled           = true
          log_retention_in_days = 7
          ike_versions          = ["ikev2"]
        }

        tunnel2 = {
          inside_cidr           = null # CIDR block of the second tunnel
          log_enabled           = true
          log_retention_in_days = 7
          ike_versions          = ["ikev2"]
        }
      }

      // routes are valid when static_routes_only = true
      routes = [
        {
          destination_cidr_block = "10.0.0.0/16"
        },
        {
          destination_cidr_block = "10.3.0.0/16"
        }
      ]
    }
  }

  tags = module.tags.tags
}
