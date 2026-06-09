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
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 4.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
    http = {
      source  = "hashicorp/http"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "arun"
}

provider "keycloak" {
  url       = var.keycloak_config.url
  client_id = var.keycloak_config.client_id
  username  = var.keycloak_config.username
  password  = var.keycloak_config.password
  base_path = ""
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
## Keycloak realm — created only if create_keycloak_realm = true.
## Set create_keycloak_realm = false if the realm already exists.
################################################################################
resource "keycloak_realm" "this" {
  count   = var.create_keycloak_realm ? 1 : 0
  realm   = var.keycloak_config.realm
  enabled = true
}

################################################################################
## Keycloak IdP metadata — fetched live so the IAM SAML provider always has
## the current signing certificate, even after realm recreation.
################################################################################
data "http" "keycloak_metadata" {
  url = "${var.keycloak_config.url}/realms/${var.keycloak_config.realm}/protocol/saml/descriptor"

  depends_on = [keycloak_realm.this]
}

################################################################################
## lookups
################################################################################
data "aws_vpc" "this" {
  dynamic "filter" {
    for_each = var.vpc_id != null ? [] : [1]
    content {
      name   = "tag:Name"
      values = [coalesce(var.vpc_name, "${var.namespace}-${var.environment}-vpc")]
    }
  }
  id = var.vpc_id
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  dynamic "filter" {
    for_each = length(var.subnet_ids) > 0 ? [var.subnet_ids] : []
    content {
      name   = "subnet-id"
      values = filter.value
    }
  }

  dynamic "filter" {
    for_each = length(var.subnet_ids) == 0 ? [1] : []
    content {
      name = "tag:Name"
      values = length(var.subnet_names) > 0 ? var.subnet_names : [
        "${var.namespace}-${var.environment}-private-subnet-private-${var.region}a",
        "${var.namespace}-${var.environment}-private-subnet-private-${var.region}b",
      ]
    }
  }
}

################################################################################
## CA certificate
################################################################################
module "ca" {
  source = "../../modules/certificate"

  name = "${var.namespace}-${var.environment}-keycloak-vpn-ca"
  type = "ca"
  subject = {
    common_name  = "ca.${var.namespace}.vpn"
    organization = var.namespace
  }
  environment = var.environment
  namespace   = var.namespace

  import_to_acm    = true
  store_in_ssm     = true
  store_it_locally = false

  tags = module.tags.tags
}

################################################################################
## VPN (Keycloak SAML federated authentication)
################################################################################
module "vpn" {
  source = "../../"

  name        = "${var.namespace}-${var.environment}-keycloak-client-vpn"
  namespace   = var.namespace
  environment = var.environment
  vpc_id      = data.aws_vpc.this.id

  client_vpn_config = {
    create            = true
    client_cidr_block = var.client_cidr_block != null ? var.client_cidr_block : cidrsubnet(data.aws_vpc.this.cidr_block, 6, 24)

    server_certificate_data = {
      create             = true
      common_name        = "${var.namespace}-${var.environment}.server.keycloak-vpn"
      organization       = var.namespace
      ca_cert_pem        = module.ca.ca_cert_pem
      ca_private_key_pem = module.ca.private_key_pem
    }

    authentication_options = [{ type = "federated-authentication" }]

    iam_saml_provider_enabled = true
    iam_saml_provider_name    = var.iam_saml_provider_name
    ## AWS requires WantAuthnRequestsSigned="false" in the IdP metadata.
    ## Keycloak 26 hardcodes it to "true", so we patch it here.
    saml_metadata_document_content = replace(
      data.http.keycloak_metadata.response_body,
      "WantAuthnRequestsSigned=\"true\"",
      "WantAuthnRequestsSigned=\"false\""
    )

    authorization_options = {
      "allow-vpc" = {
        target_network_cidr  = data.aws_vpc.this.cidr_block
        access_group_id      = null
        authorize_all_groups = true
      }
    }

    split_tunnel        = true
    self_service_portal = "disabled"
    subnet_ids          = data.aws_subnets.private.ids
  }

  tags = module.tags.tags

  depends_on = [keycloak_realm.this]
}

################################################################################
## Keycloak SAML client for AWS Client VPN
################################################################################
module "keycloak_vpn_client" {
  source = "../../modules/keycloak-vpn-client"

  keycloak_url       = var.keycloak_config.url
  keycloak_client_id = var.keycloak_config.client_id
  keycloak_username  = var.keycloak_config.username
  keycloak_password  = var.keycloak_config.password
  keycloak_realm     = var.keycloak_config.realm
  vpn_users          = var.keycloak_config.vpn_users
  tags               = module.tags.tags

  depends_on = [keycloak_realm.this]
}
