
################################################################################
## network
################################################################################
data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = ["Network-Endpoints"]
  }

  provider = aws.network-prod
}

data "aws_security_groups" "security_groups" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  provider = aws.network-prod
}

data "aws_acm_certificate" "cert" {
  domain = "hssc-dev-client-vpn.vpn.server"
  types  = ["IMPORTED"]

  provider = aws.network-prod
}
