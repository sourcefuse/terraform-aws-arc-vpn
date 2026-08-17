region       = "us-east-1"
namespace    = "arc"
environment  = "poc"
project_name = "arc-vpn-test"

vpc_id = "vpc-01234567890abcdef0"
subnet_ids = [
  "subnet-1234567890abcdef0",
  "subnet-abcdef01234567890",
]

client_cidr_block      = "172.31.128.0/22"
iam_saml_provider_name = "keycloak-aws-sso-client-vpn"

create_keycloak_realm = true

keycloak_config = {
  create    = true
  url       = "https://keycloak.arc-poc.link"
  realm     = "aws-sso"
  client_id = "admin-cli"
  username  = "admin"

  vpn_users = {
    "user" = {
      email      = "user@example.com"
      first_name = "user"
      last_name  = "1"
    },
  }
}
