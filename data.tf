
################################################################################
## network
################################################################################
data "aws_vpc" "vpc" {
  filter {
    name   = "<filter-parameter>"
    values = [<parameter-value(s)>]
  }

  provider = aws.<custom-provider>      ## replace the custom-provider with the provider created for the applicable account profile. This is applicable in a multi-account architecture and you must have created a provider block with the profile for it to work.
}

data "aws_security_groups" "security_groups" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  provider = aws.<custom-provider>      ## replace the custom-provider with the provider created for the applicable account profile. This is applicable in a multi-account architecture and you must have created a provider block with the profile for it to work.
}

data "aws_acm_certificate" "cert" {
  domain = "arc-dev-client-vpn.vpn.server"
  types  = ["IMPORTED"]

  provider = aws.<custom-provider>      ## replace the custom-provider with the provider created for the applicable account profile. This is applicable in a multi-account architecture and you must have created a provider block with the profile for it to work.
}

## Sample custom-provider block
provider "aws" {
  region = var.region
  profile = <profile_name>    #replace with applicable aws profile name
  alias = <custom-provider>   #replace with the name you would like to use
}
