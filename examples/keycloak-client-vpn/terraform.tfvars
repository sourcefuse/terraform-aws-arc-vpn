region       = "us-east-1"
namespace    = "arc"
environment  = "poc"
project_name = "arc-example"

vpc_id = "vpc-031234567890"
subnet_ids = [
  "subnet-031234567890",
]

client_cidr_block      = "172.31.128.0/22"
iam_saml_provider_name = "keycloak-aws-sso-client-vpn"

create_keycloak_realm = true # realm already exists

keycloak_config = {
  create    = true
  url       = "https://keycloak.xyzorg.link"
  realm     = "aws-sso"
  client_id = "admin-cli"
  username  = "admin"
  password  = "ywtRdWQBw8CA4LA("

  vpn_users = {
    "user1" = {
      email      = "user1@example.com"
      first_name = "first"
      last_name  = "last"
    }
    "user2" = {
      email      = "user2@example.com"
      first_name = "first"
      last_name  = "last"
    }
  }
}
