region       = "us-east-1"
namespace    = "arc"
environment  = "poc"
project_name = "arc-vpn-test"

vpc_id = "vpc-0e6c09980580ecbf6"
subnet_ids = [
  "subnet-066d0c78479b72e77",
  "subnet-064b80a494fed9835",
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
    "arun" = {
      email      = "arun.sai@sourcefuse.com"
      first_name = "Arun"
      last_name  = "Sai"
    },
    "vijay" = {
      email      = "vijay.stephen@sourcefuse.com"
      first_name = "vijay"
      last_name  = "stephen"
    }
  }
}
