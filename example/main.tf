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

################################################################################
## lookups
################################################################################
// TODO - add your data lookups here for things like vpc id / security groups

################################################################################
## vpn
################################################################################
// TODO - add example configuration here
// TODO - test the example to make sure everything works fine
module "vpn" {
  source = "../"

  tags = {}
}
