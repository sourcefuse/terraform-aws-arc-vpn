region       = "us-east-1"
namespace    = "arc"
environment  = "poc"
project_name = "arc-example"

vpc_id = "vpc-03ccd00027839c2f0"
subnet_ids = [
  "subnet-035984b4884cec38f",
]

client_cidr_block      = "172.31.128.0/22"
iam_saml_provider_name = "keycloak-aws-sso-client-vpn"

create_keycloak_realm = true # realm already exists

keycloak_config = {
  create    = true
  url       = "https://keycloak.arc-poc.link"
  realm     = "aws-sso"
  client_id = "admin-cli"
  username  = "admin"
  password  = "ywtRdWQBw8CA4LA("

  vpn_users = {
    "arun" = {
      email      = "arun.sai@sourcefuse.com"
      first_name = "Arun"
      last_name  = "Sai"
    }
    "mani" = {
      email      = "manikanta.sadurla@sourcefuse.com"
      first_name = "manikanta"
      last_name  = "sadurla"
    }
  }
}
