![Module Structure](./static/banner.png)

# [terraform-aws-arc-vpn](https://github.com/sourcefuse/terraform-aws-arc-vpn)

<a href="https://github.com/sourcefuse/terraform-aws-arc-vpn/releases/latest"><img src="https://img.shields.io/github/release/sourcefuse/terraform-aws-arc-vpn.svg?style=for-the-badge" alt="Latest Release"/></a> <a href="https://github.com/sourcefuse/terraform-aws-arc-vpn/commits"><img src="https://img.shields.io/github/last-commit/sourcefuse/terraform-aws-arc-vpn.svg?style=for-the-badge" alt="Last Updated"/></a> ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white) ![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white)

[![Quality gate](https://sonarcloud.io/api/project_badges/quality_gate?project=sourcefuse_terraform-aws-arc-vpn)](https://sonarcloud.io/summary/new_code?id=sourcefuse_terraform-aws-arc-vpn)

[![Snyk](https://github.com/sourcefuse/terraform-aws-refarch-vpn/actions/workflows/test.yml/badge.svg)](https://github.com/sourcefuse/c/actions/workflows/test.yml)

## Overview

SourceFuse AWS Reference Architecture (ARC) Terraform module for managing a Client VPN.

For more information about this repository and its usage, please see [Terraform AWS ARC CloudFront Usage Guide](https://github.com/sourcefuse/terraform-aws-arc-vpn/blob/main/docs/module-usage-guide/README.md).

## Usage

To see a full example, check out the [main.tf](https://github.com/sourcefuse/terraform-aws-arc-vpn/blob/main/example/main.tf) file in the example folder.

```tcl
module "this" {
  source  = "sourcefuse/arc-vpn/aws"
  version = "1.0.0"
  vpc_id = data.aws_vpc.this.id

  authentication_options_type                       = "certificate-authentication"
  authentication_options_root_certificate_chain_arn = module.self_signed_cert_root.certificate_arn

  ## access
  client_vpn_authorize_all_groups = true
  client_vpn_subnet_ids           = data.aws_subnets.private.ids
  client_vpn_target_network_cidr  = data.aws_vpc.this.cidr_block

  ## self signed certificate
  create_self_signed_server_cert             = true
  self_signed_server_cert_server_common_name = "${var.namespace}-${var.environment}.arc-vpn-example.client"
  self_signed_server_cert_organization_name  = var.namespace
  self_signed_server_cert_ca_pem             = module.self_signed_cert_ca.certificate_pem
  self_signed_server_cert_private_ca_key_pem = join("", data.aws_ssm_parameter.ca_key[*].value)

  ## client vpn
  client_cidr             = cidrsubnet(data.aws_vpc.this.cidr_block, 6, 1)
  client_vpn_name         = "${var.namespace}-${var.environment}-client-vpn-example"
  client_vpn_gateway_name = "${var.namespace}-${var.environment}-vpn-gateway-example"

  tags = module.tags.tags
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.4, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0, < 6.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_client_vpn"></a> [client\_vpn](#module\_client\_vpn) | ./modules/client-vpn | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_vpn_config"></a> [client\_vpn\_config](#input\_client\_vpn\_config) | VPN configuration options including certs and vpn settings | <pre>object({<br>    name   = string<br>    create = optional(bool, false)<br>    # certs<br>    self_signed_cert_data = optional(object({<br>      create             = optional(bool, true)<br>      secret_path_format = optional(string, "/%s.%s")<br>      server_common_name = optional(string, "")<br>      organization_name  = optional(string, "")<br>      allowed_uses = optional(list(string), [<br>        "key_encipherment",<br>        "digital_signature",<br>        "server_auth"<br>      ])<br>      ca_pem             = optional(string, "")<br>      private_ca_key_pem = optional(string, "")<br>    }))<br><br><br>    # vpn settings<br>    iam_saml_provider_enabled      = optional(bool, false)<br>    iam_saml_provider_name         = optional(string, null)<br>    saml_metadata_document_content = optional(string, null)<br>    client_cidr_block              = string<br>    split_tunnel                   = optional(bool, true)<br>    self_service_portal            = optional(string, "disabled")<br>    dns_servers                    = optional(list(string), ["1.1.1.1", "1.0.0.1"])<br><br>    # logging options<br>    log_options = optional(object({<br>      enabled               = bool<br>      cloudwatch_log_stream = optional(string, null)<br>      cloudwatch_log_group  = optional(string, null)<br>      }), {<br>      enabled = false<br>    })<br><br>    # authentication options<br>    authentication_options = list(object({<br>      active_directory_id            = optional(string, null)<br>      root_certificate_chain_arn     = optional(string, null)<br>      saml_provider_arn              = optional(string, null)<br>      self_service_saml_provider_arn = optional(string, null)<br>      type                           = string<br>    }))<br><br>    # server and transport protocol<br>    client_server_certificate_arn    = optional(string, null)<br>    client_server_transport_protocol = optional(string, "tcp")<br><br>    # security and network associations<br>    security_group_data = optional(object({<br>      client_vpn_additional_security_group_ids = optional(list(string), [])<br>      ingress_rules = list(object({<br>        description        = optional(string, "")<br>        from_port          = number<br>        to_port            = number<br>        protocol           = any<br>        cidr_blocks        = optional(list(string), [])<br>        security_group_ids = optional(list(string), [])<br>        ipv6_cidr_blocks   = optional(list(string), [])<br>      }))<br>      egress_rules = list(object({<br>        description        = optional(string, "")<br>        from_port          = number<br>        to_port            = number<br>        protocol           = any<br>        cidr_blocks        = optional(list(string), [])<br>        security_group_ids = optional(list(string), [])<br>        ipv6_cidr_blocks   = optional(list(string), [])<br>      }))<br>      }),<br>      {<br>        ingress_rules = [<br>          {<br>            description = "VPN ingress to 443"<br>            from_port   = 443<br>            to_port     = 443<br>            protocol    = "tcp"<br>          }<br>        ]<br>        egress_rules = [<br>          {<br>            description = "VPN egress to internet"<br>            from_port   = 0<br>            to_port     = 0<br>            protocol    = -1<br>            cidr_blocks = ["0.0.0.0/0"]<br>          }<br>        ]<br>      }<br>    )<br><br>    subnet_ids = list(string)<br><br>    # authorization options<br>    authorization_options = map(object({<br>      target_network_cidr  = string<br>      access_group_id      = optional(string, null)<br>      authorize_all_groups = optional(bool, true)<br>    }))<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to every applicable resource | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the target network VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_self_signed_cert_server_certificate_arn"></a> [client\_self\_signed\_cert\_server\_certificate\_arn](#output\_client\_self\_signed\_cert\_server\_certificate\_arn) | Self signed certificate server certificate ARN |
| <a name="output_client_vpn_arn"></a> [client\_vpn\_arn](#output\_client\_vpn\_arn) | The client vpn ARN |
| <a name="output_client_vpn_id"></a> [client\_vpn\_id](#output\_client\_vpn\_id) | The client vpn ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Versioning

while Contributing or doing git commit please specify the breaking change in your commit message whether its major,minor or patch

For Example

```sh
git commit -m "your commit message #major"
```
By specifying this , it will bump the version and if you don't specify this in your commit message then by default it will consider patch and will bump that accordingly

## Development

### Prerequisites

- [terraform](https://learn.hashicorp.com/terraform/getting-started/install#installing-terraform)
- [terraform-docs](https://github.com/segmentio/terraform-docs)
- [pre-commit](https://pre-commit.com/#install)
- [golang](https://golang.org/doc/install#install)
- [golint](https://github.com/golang/lint#installation)

### Configurations

- Configure pre-commit hooks
  ```sh
  pre-commit install
  ```

### Tests

- Tests are available in `test` directory
- Configure the dependencies
  ```sh
  cd test/
  go mod init github.com/sourcefuse/terraform-aws-refarch-vpn
  go get github.com/gruntwork-io/terratest/modules/terraform
  ```
- Now execute the test
  ```sh
  go test -timeout  30m
  ```

## Authors

This project is authored by:

- SourceFuse
