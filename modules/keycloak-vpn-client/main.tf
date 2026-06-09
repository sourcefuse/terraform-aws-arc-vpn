################################################################################
## Keycloak SAML Client for AWS Client VPN
##
## Creates a SAML client in an existing Keycloak realm that allows users to
## authenticate to an AWS Client VPN endpoint via Keycloak SSO.
##
## What this module does:
##   - Looks up the existing Keycloak realm (does not create it)
##   - Sets the realm assertion lifespan to 5 min (required for VPN auth flow)
##   - Creates the SAML client with Client ID: urn:amazon:webservices:clientvpn
##   - Adds an email attribute mapper (required by AWS Client VPN)
##   - Optionally creates VPN users with auto-generated passwords stored in SSM
################################################################################

data "keycloak_realm" "this" {
  realm = var.keycloak_realm
}

## AWS Client VPN SAML flow takes longer than Keycloak's default 60s window.
## Set via API to avoid 409 conflict when the realm already exists.
resource "null_resource" "realm_lifespan" {
  triggers = {
    realm = var.keycloak_realm
    url   = var.keycloak_url
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN=$(curl -s -X POST "${var.keycloak_url}/realms/master/protocol/openid-connect/token" \
        -d "client_id=${var.keycloak_client_id}&username=${var.keycloak_username}&password=${var.keycloak_password}&grant_type=password" \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
      curl -s -o /dev/null -X PUT \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        "${var.keycloak_url}/admin/realms/${var.keycloak_realm}" \
        -d '{"accessCodeLifespan":300,"accessCodeLifespanLogin":300,"accessCodeLifespanUserAction":300}'
    EOT
  }
}

resource "keycloak_saml_client" "this" {
  realm_id  = data.keycloak_realm.this.id
  client_id = "urn:amazon:webservices:clientvpn"
  name      = "AWS Client VPN"
  enabled   = true

  ## Required by AWS Client VPN
  sign_documents            = true
  sign_assertions           = true
  include_authn_statement   = true
  client_signature_required = false
  force_post_binding        = true
  name_id_format            = "email"
  force_name_id_format      = true

  ## AWS VPN Client callback URLs
  valid_redirect_uris = [
    "http://127.0.0.1:35001",
    "https://self-service.clientvpn.amazonaws.com/api/auth/sso/saml",
  ]
}

## Remove role_list default scope via API.
## role_list injects IAM Identity Center Role attributes into the VPN assertion
## which causes AWS to reject the credentials with "incorrect credentials".
resource "null_resource" "remove_role_list_scope" {
  triggers = {
    client_id = keycloak_saml_client.this.id
    realm     = var.keycloak_realm
  }

  provisioner "local-exec" {
    command = <<-EOT
      TOKEN=$(curl -s -X POST "${var.keycloak_url}/realms/master/protocol/openid-connect/token" \
        -d "client_id=${var.keycloak_client_id}&username=${var.keycloak_username}&password=${var.keycloak_password}&grant_type=password" \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['access_token'])")
      SCOPE_ID=$(curl -s -H "Authorization: Bearer $TOKEN" \
        "${var.keycloak_url}/admin/realms/${var.keycloak_realm}/client-scopes" \
        | python3 -c "import sys,json; s=[x for x in json.load(sys.stdin) if x['name']=='role_list']; print(s[0]['id'] if s else '')")
      if [ -n "$SCOPE_ID" ]; then
        curl -s -o /dev/null -X DELETE \
          -H "Authorization: Bearer $TOKEN" \
          "${var.keycloak_url}/admin/realms/${var.keycloak_realm}/clients/${self.triggers.client_id}/default-client-scopes/$SCOPE_ID"
      fi
    EOT
  }

  depends_on = [keycloak_saml_client.this]
}

## AWS Client VPN requires at least one AttributeStatement in the SAML assertion.
## saml-user-attribute-mapper correctly maps the Keycloak email field.
resource "keycloak_generic_protocol_mapper" "email_attr" {
  realm_id        = data.keycloak_realm.this.id
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

################################################################################
## VPN Users (optional)
################################################################################

resource "random_password" "vpn_user" {
  for_each         = var.vpn_users
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+?"
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "keycloak_user" "vpn_user" {
  for_each       = var.vpn_users
  realm_id       = data.keycloak_realm.this.id
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

## Store each user's initial password in SSM SecureString.
## Path: /arc-vpn/<realm>/users/<email>/password
resource "aws_ssm_parameter" "vpn_user_password" {
  for_each    = var.vpn_users
  name        = "/arc-vpn/${var.keycloak_realm}/users/${replace(each.value.email, "@", "_at_")}/password"
  description = "Initial VPN password for ${each.value.email}"
  type        = "SecureString"
  value       = random_password.vpn_user[each.key].result
  tags        = var.tags
}
