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
## Keycloak SAML client for AWS Client VPN (inlined)
################################################################################

## AWS Client VPN SAML flow takes longer than Keycloak's default 60s window.
## Set via API to avoid 409 conflict when the realm already exists.
resource "null_resource" "realm_lifespan" {
  triggers = {
    realm = var.keycloak_config.realm
    url   = var.keycloak_config.url
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN=$(curl -s -X POST "${var.keycloak_config.url}/realms/master/protocol/openid-connect/token" \
        -d "client_id=${var.keycloak_config.client_id}&username=${var.keycloak_config.username}&password=${var.keycloak_config.password}&grant_type=password" \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
      curl -s -o /dev/null -X PUT \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        "${var.keycloak_config.url}/admin/realms/${var.keycloak_config.realm}" \
        -d '{"accessCodeLifespan":300,"accessCodeLifespanLogin":300,"accessCodeLifespanUserAction":300}'
    EOT
  }

  depends_on = [keycloak_realm.this]
}

resource "keycloak_saml_client" "this" {
  realm_id  = var.keycloak_config.realm
  client_id = "urn:amazon:webservices:clientvpn"
  name      = "AWS Client VPN"
  enabled   = true

  sign_documents            = true
  sign_assertions           = true
  include_authn_statement   = true
  client_signature_required = false
  force_post_binding        = true
  name_id_format            = "email"
  force_name_id_format      = true

  valid_redirect_uris = [
    "http://127.0.0.1:35001",
    "https://self-service.clientvpn.amazonaws.com/api/auth/sso/saml",
  ]

  depends_on = [keycloak_realm.this]
}

## Remove role_list default scope via API.
resource "null_resource" "remove_role_list_scope" {
  triggers = {
    client_id = keycloak_saml_client.this.id
    realm     = var.keycloak_config.realm
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN=$(curl -s -X POST "${var.keycloak_config.url}/realms/master/protocol/openid-connect/token" \
        -d "client_id=${var.keycloak_config.client_id}&username=${var.keycloak_config.username}&password=${var.keycloak_config.password}&grant_type=password" \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
      SCOPE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
        "${var.keycloak_config.url}/admin/realms/${var.keycloak_config.realm}/client-scopes" \
        | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin) if x['name']=='role_list']; print(s[0]['id'] if s else '')")
      if [ -n "$SCOPE_ID" ]; then
        curl -s -o /dev/null -X DELETE \
          -H "Authorization: Bearer $TOKEN" \
          "${var.keycloak_config.url}/admin/realms/${var.keycloak_config.realm}/clients/${self.triggers.client_id}/default-client-scopes/$SCOPE_ID"
      fi
    EOT
  }

  depends_on = [keycloak_saml_client.this]
}

resource "keycloak_generic_protocol_mapper" "email_attr" {
  realm_id        = var.keycloak_config.realm
  client_id       = keycloak_saml_client.this.id
  name            = "email-attr"
  protocol        = "saml"
  protocol_mapper = "saml-user-attribute-mapper"
  config = {
    "user.attribute"       = "email"
    "attribute.name"       = "email"
    "attribute.nameformat" = "Basic"
    "friendly.name"        = "email"
  }
}

resource "random_password" "vpn_user" {
  for_each         = var.keycloak_config.vpn_users
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "keycloak_user" "vpn_user" {
  for_each       = var.keycloak_config.vpn_users
  realm_id       = var.keycloak_config.realm
  username       = each.value.email
  email          = each.value.email
  first_name     = each.value.first_name
  last_name      = each.value.last_name
  email_verified = true
  enabled        = true

  initial_password {
    value     = random_password.vpn_user[each.key].result
    temporary = true
  }
}

resource "aws_ssm_parameter" "vpn_user_password" {
  for_each    = var.keycloak_config.vpn_users
  name        = "/arc-vpn/${var.keycloak_config.realm}/users/${replace(each.value.email, "@", "_at_")}/password"
  description = "Initial VPN password for ${each.value.email}"
  type        = "SecureString"
  value       = random_password.vpn_user[each.key].result
  tags        = module.tags.tags
}
