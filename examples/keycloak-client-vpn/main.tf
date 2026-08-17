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
      version = "< 5.8.0"
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
  region = var.region
}

################################################################################
## Keycloak admin password — fetched from SSM
################################################################################
data "aws_ssm_parameter" "keycloak_admin_password" {
  name            = "/arc-poc/keycloak/admin-password"
  with_decryption = true
}

provider "keycloak" {
  url       = var.keycloak_config.url
  client_id = var.keycloak_config.client_id
  username  = var.keycloak_config.username
  password  = data.aws_ssm_parameter.keycloak_admin_password.value
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
## access_code_lifespan* are set to 5m (300s) because the AWS Client VPN
## SAML flow takes longer than Keycloak's default 60s window.
################################################################################
resource "keycloak_realm" "this" {
  count = var.create_keycloak_realm ? 1 : 0

  # Required
  realm   = var.keycloak_config.realm
  enabled = true

  # General
  display_name                  = "aws realm"
  display_name_html             = null
  user_managed_access           = false
  organizations_enabled         = false
  attributes                    = {}
  internal_id                   = null
  terraform_deletion_protection = false

  # Login Settings
  registration_allowed           = false
  registration_email_as_username = false
  edit_username_allowed          = false
  reset_password_allowed         = false
  remember_me                    = false
  verify_email                   = false
  login_with_email_allowed       = true
  duplicate_emails_allowed       = false
  ssl_required                   = "external" # "none" | "external" | "all"

  # Themes
  login_theme   = null
  account_theme = null
  admin_theme   = null
  email_theme   = null

  # Password Policy
  password_policy = null
  # example: "upperCase(1) and length(8) and forceExpiredPasswordChange(365) and notUsername"

  # Authentication
  admin_permissions_enabled = false

  # Authentication Flow Bindings
  browser_flow               = null
  registration_flow          = null
  direct_grant_flow          = null
  reset_credentials_flow     = null
  client_authentication_flow = null
  docker_authentication_flow = null
  first_broker_login_flow    = null

  # Tokens — Go duration strings e.g. "30m", "1h", "12h", "30d"
  default_signature_algorithm              = null
  revoke_refresh_token                     = false
  refresh_token_max_reuse                  = null
  sso_session_idle_timeout                 = null
  sso_session_max_lifespan                 = null
  sso_session_idle_timeout_remember_me     = null
  sso_session_max_lifespan_remember_me     = null
  offline_session_idle_timeout             = null
  offline_session_max_lifespan             = null
  offline_session_max_lifespan_enabled     = false
  client_session_idle_timeout              = null
  client_session_max_lifespan              = null
  access_token_lifespan                    = null
  access_token_lifespan_for_implicit_flow  = null
  action_token_generated_by_user_lifespan  = null
  action_token_generated_by_admin_lifespan = null
  oauth2_device_code_lifespan              = null
  oauth2_device_polling_interval           = null # seconds

  # AWS Client VPN SAML flow needs more than the default 60s
  access_code_lifespan             = "5m"
  access_code_lifespan_login       = "5m"
  access_code_lifespan_user_action = "5m"

  # Default Client Scopes
  default_default_client_scopes  = []
  default_optional_client_scopes = []

  # SMTP (commented out — configure if email notifications are needed)
  # smtp_server {
  #   host                  = "smtp.example.com"
  #   port                  = 587
  #   from                  = "no-reply@example.com"
  #   from_display_name     = null
  #   reply_to              = null
  #   reply_to_display_name = null
  #   envelope_from         = null
  #   starttls              = true
  #   ssl                   = false
  #   auth {
  #     username = "smtp-user"
  #     password = "smtp-password"
  #   }
  # }

  # Internationalization (commented out — enable if multi-language support needed)
  # internationalization {
  #   supported_locales = ["en"]
  #   default_locale    = "en"
  # }

  # Security Defenses
  security_defenses {
    headers {
      x_frame_options                     = "SAMEORIGIN"
      content_security_policy             = "frame-src 'self'; frame-ancestors 'self'; object-src 'none';"
      content_security_policy_report_only = ""
      x_content_type_options              = "nosniff"
      x_robots_tag                        = "none"
      x_xss_protection                    = "1; mode=block"
      strict_transport_security           = "max-age=31536000; includeSubDomains"
      referrer_policy                     = "no-referrer"
    }
    brute_force_detection {
      permanent_lockout                = false
      max_temporary_lockouts           = 0
      max_login_failures               = 30
      wait_increment_seconds           = 60
      quick_login_check_milli_seconds  = 1000
      minimum_quick_login_wait_seconds = 60
      max_failure_wait_seconds         = 900
      failure_reset_time_seconds       = 43200
    }
  }

  # OTP Policy (commented out — defaults are fine for most use cases)
  # otp_policy {
  #   type              = "totp"   # "totp" | "hotp"
  #   algorithm         = "HmacSHA1"
  #   digits            = 6
  #   initial_counter   = 2
  #   look_ahead_window = 1
  #   period            = 30
  #   code_reusable     = false
  # }

  # WebAuthn Policy (commented out — enable if hardware key / passkey support needed)
  # web_authn_policy {
  #   relying_party_entity_name         = "Example"
  #   relying_party_id                  = "keycloak.example.com"
  #   signature_algorithms              = ["ES256", "RS256"]
  #   attestation_conveyance_preference = "not specified"
  #   authenticator_attachment          = "not specified"
  #   discoverable_credential           = "not specified"
  #   user_verification_requirement     = "not specified"
  #   create_timeout                    = 0
  #   avoid_same_authenticator_register = false
  #   acceptable_aaguids                = []
  #   extra_origins                     = []
  # }

  # WebAuthn Passwordless Policy (commented out)
  # web_authn_passwordless_policy {
  #   relying_party_entity_name         = "Example"
  #   relying_party_id                  = "keycloak.example.com"
  #   signature_algorithms              = ["ES256", "RS256"]
  #   attestation_conveyance_preference = "not specified"
  #   authenticator_attachment          = "not specified"
  #   discoverable_credential           = "not specified"
  #   user_verification_requirement     = "not specified"
  #   create_timeout                    = 0
  #   avoid_same_authenticator_register = false
  #   acceptable_aaguids                = []
  #   extra_origins                     = []
  #   passwordless_passkeys_enabled     = false
  # }
}

################################################################################
## Keycloak IdP metadata — fetched live, patched, and stored in SSM.
## The VPN module reads from SSM so the metadata is versioned and auditable.
################################################################################
data "http" "keycloak_metadata" {
  url = "${var.keycloak_config.url}/realms/${var.keycloak_config.realm}/protocol/saml/descriptor"

  depends_on = [keycloak_realm.this]
}

resource "aws_ssm_parameter" "keycloak_metadata" {
  name        = "/${var.namespace}/${var.environment}/keycloak/saml-metadata"
  description = "Keycloak SAML IdP metadata for AWS Client VPN"
  type        = "String"
  overwrite   = true
  ## AWS requires WantAuthnRequestsSigned="false"; Keycloak 26 hardcodes "true".
  value = replace(
    data.http.keycloak_metadata.response_body,
    "WantAuthnRequestsSigned=\"true\"",
    "WantAuthnRequestsSigned=\"false\""
  )
  tags = module.tags.tags
}

data "aws_ssm_parameter" "keycloak_metadata" {
  name       = aws_ssm_parameter.keycloak_metadata.name
  depends_on = [aws_ssm_parameter.keycloak_metadata]
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
## Certificates — CA only (for server certificate)
################################################################################
locals {
  certificates = {
    ca = {
      name               = "${var.namespace}-${var.environment}-keycloak-vpn-ca"
      type               = "ca"
      common_name        = "ca.${var.namespace}.vpn"
      ca_cert_pem        = null
      ca_private_key_pem = null
      import_to_acm      = true
      store_in_ssm       = true
      store_it_locally   = false
    }
  }
}

module "certificates" {
  for_each = local.certificates
  source   = "../../modules/certificate"

  name = each.value.name
  type = each.value.type
  subject = {
    common_name  = each.value.common_name
    organization = var.namespace
  }
  environment = var.environment
  namespace   = var.namespace

  ca_cert_pem        = null
  ca_private_key_pem = null

  import_to_acm    = each.value.import_to_acm
  store_in_ssm     = each.value.store_in_ssm
  store_it_locally = each.value.store_it_locally

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
      ca_cert_pem        = module.certificates["ca"].ca_cert_pem
      ca_private_key_pem = module.certificates["ca"].private_key_pem
    }

    authentication_options = [
      # AWS VPN Client → SAML/Keycloak browser login only
      {
        type                           = "federated-authentication"
        root_certificate_chain_arn     = null
        active_directory_id            = null
        saml_provider_arn              = null
        self_service_saml_provider_arn = null
      }
    ]

    iam_saml_provider_enabled      = true
    iam_saml_provider_name         = var.iam_saml_provider_name
    saml_metadata_document_content = data.aws_ssm_parameter.keycloak_metadata.value

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

resource "keycloak_saml_client" "this" {
  # Required
  realm_id  = var.keycloak_config.realm
  client_id = "urn:amazon:webservices:clientvpn"

  # General
  name                      = "AWS Client VPN"
  enabled                   = true
  description               = null
  login_theme               = null
  always_display_in_console = false
  consent_required          = false
  full_scope_allowed        = null

  # SAML document/assertion signing
  sign_documents            = true
  sign_assertions           = true
  include_authn_statement   = true
  client_signature_required = false

  # Encryption (disabled — AWS Client VPN does not send encrypted assertions)
  encrypt_assertions = false
  # encryption_algorithm           = null  # "AES_256_GCM" | "AES_192_GCM" | "AES_128_GCM" | "AES_256_CBC" | "AES_192_CBC" | "AES_128_CBC"
  # encryption_key_algorithm       = null  # "RSA-OAEP-11" | "RSA-OAEP-MGF1P" | "RSA1_5"
  # encryption_digest_method       = null  # "SHA-512" | "SHA-256" | "SHA-1"
  # encryption_mask_generation_function = null  # "mgf1sha1" | "mgf1sha256" etc.
  # encryption_certificate         = null

  # Binding / protocol
  force_post_binding   = true
  front_channel_logout = true

  # Name ID
  name_id_format       = "email"
  force_name_id_format = true

  # Signature
  signature_algorithm     = null # "RSA_SHA256" recommended; null = realm default
  signature_key_name      = null # "KEY_ID" | "CERT_SUBJECT" | "NONE"
  canonicalization_method = null # "EXCLUSIVE" | "EXCLUSIVE_WITH_COMMENTS" | "INCLUSIVE" | "INCLUSIVE_WITH_COMMENTS"

  # URLs
  root_url                            = null
  base_url                            = null
  master_saml_processing_url          = null
  assertion_consumer_post_url         = null
  assertion_consumer_redirect_url     = null
  logout_service_post_binding_url     = null
  logout_service_redirect_binding_url = null

  valid_redirect_uris = [
    "http://127.0.0.1:35001",
    "https://self-service.clientvpn.amazonaws.com/api/auth/sso/saml",
  ]

  # IDP-initiated SSO
  idp_initiated_sso_url_name    = null
  idp_initiated_sso_relay_state = null

  # Signing certs (not needed — client_signature_required = false)
  signing_certificate = null
  signing_private_key = null

  # Authentication flow binding overrides (optional block)
  # authentication_flow_binding_overrides {
  #   browser_id      = null
  #   direct_grant_id = null
  # }

  # Extra custom config attributes
  extra_config = {}

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
        -d "client_id=${var.keycloak_config.client_id}&username=${var.keycloak_config.username}&password=${data.aws_ssm_parameter.keycloak_admin_password.value}&grant_type=password" \
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

  depends_on = [keycloak_realm.this]
}

resource "aws_ssm_parameter" "vpn_user_password" {
  for_each    = var.keycloak_config.vpn_users
  name        = "/arc-vpn/${var.keycloak_config.realm}/users/${replace(each.value.email, "@", "_at_")}/password"
  description = "Initial VPN password for ${each.value.email}"
  type        = "SecureString"
  value       = random_password.vpn_user[each.key].result
  tags        = module.tags.tags
}
