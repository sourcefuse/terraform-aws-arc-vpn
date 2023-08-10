# terraform-aws-refarch-vpn

## Overview

SourceFuse AWS Reference Architecture (ARC) Terraform module for managing VPN.

## Usage

To see a full example, check out the [main.tf](./example/main.tf) file in the example folder.  

```hcl
module "this" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-vpn"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.11.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_acm_request_root_certificate"></a> [acm\_request\_root\_certificate](#module\_acm\_request\_root\_certificate) | cloudposse/acm-request-certificate/aws | 0.15.1 |
| <a name="module_acm_request_server_certificate"></a> [acm\_request\_server\_certificate](#module\_acm\_request\_server\_certificate) | cloudposse/acm-request-certificate/aws | 0.15.1 |
| <a name="module_security_group"></a> [security\_group](#module\_security\_group) | terraform-aws-modules/security-group/aws | 5.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_client_vpn_authorization_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_authorization_rule) | resource |
| [aws_ec2_client_vpn_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_ec2_client_vpn_network_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_network_association) | resource |
| [aws_vpn_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |
| [aws_route53_zone.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnets.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_active_directory_id"></a> [active\_directory\_id](#input\_active\_directory\_id) | The active directory id for client vpn authentication | `string` | `null` | no |
| <a name="input_authorize_all_groups_for_client_vpn"></a> [authorize\_all\_groups\_for\_client\_vpn](#input\_authorize\_all\_groups\_for\_client\_vpn) | Set to `true` to authorize all groups to access the target network | `bool` | `true` | no |
| <a name="input_client_authentication_type"></a> [client\_authentication\_type](#input\_client\_authentication\_type) | Set to one of these applicable options: `federated-authentication`, `certificate-authentication` or `directory-service-authentication` | `string` | `"certificate-authentication"` | no |
| <a name="input_client_vpn_additional_security_group_ids"></a> [client\_vpn\_additional\_security\_group\_ids](#input\_client\_vpn\_additional\_security\_group\_ids) | The ids of additional securiity groups to attach to the target network | `list(string)` | `[]` | no |
| <a name="input_client_vpn_cidr"></a> [client\_vpn\_cidr](#input\_client\_vpn\_cidr) | The IPv4 address range, in CIDR notation, from which to assign client IP addresses. The CIDR block should be /22 or greater | `string` | n/a | yes |
| <a name="input_client_vpn_gateway_name"></a> [client\_vpn\_gateway\_name](#input\_client\_vpn\_gateway\_name) | The name of the client vpn gateway | `string` | `"client-vpn-gw"` | no |
| <a name="input_client_vpn_name"></a> [client\_vpn\_name](#input\_client\_vpn\_name) | The name of the client vpn | `string` | `"client-vpn"` | no |
| <a name="input_client_vpn_split_tunnel"></a> [client\_vpn\_split\_tunnel](#input\_client\_vpn\_split\_tunnel) | Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false. | `bool` | `false` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | The name of the vpn client cloudwatch log group | `string` | `"client-vpn-log-group"` | no |
| <a name="input_cloudwatch_log_stream_name"></a> [cloudwatch\_log\_stream\_name](#input\_cloudwatch\_log\_stream\_name) | The name of the vpn client cloudwatch log stream | `string` | `"client-vpn-log-stream"` | no |
| <a name="input_connection_log_enabled"></a> [connection\_log\_enabled](#input\_connection\_log\_enabled) | Set to `false` if you do not want client vpn connection log enabled | `bool` | `false` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The list of dns server ip address | `list(string)` | <pre>[<br>  "1.1.1.1",<br>  "1.0.0.1"<br>]</pre> | no |
| <a name="input_egress_rules"></a> [egress\_rules](#input\_egress\_rules) | Default list of egress rules | <pre>list(object({<br>    description = string<br>    cidr_blocks = string<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>  }))</pre> | `[]` | no |
| <a name="input_ingress_rules"></a> [ingress\_rules](#input\_ingress\_rules) | List of ingress rules | <pre>list(object({<br>    description = string<br>    cidr_blocks = string<br>    from_port   = number<br>    to_port     = number<br>    protocol    = string<br>  }))</pre> | `[]` | no |
| <a name="input_route_53_zone"></a> [route\_53\_zone](#input\_route\_53\_zone) | The name of the domain to create in route53 | `string` | `"exampledomain.com"` | no |
| <a name="input_saml_provider_arn"></a> [saml\_provider\_arn](#input\_saml\_provider\_arn) | The arn of the IAM SAML Provider name | `string` | `null` | no |
| <a name="input_self_service_portal_settings"></a> [self\_service\_portal\_settings](#input\_self\_service\_portal\_settings) | Set to `enabled` if self service portal is needed | `string` | `"disabled"` | no |
| <a name="input_self_service_saml_provider_arn"></a> [self\_service\_saml\_provider\_arn](#input\_self\_service\_saml\_provider\_arn) | The arn of the IAM self service SAML Provider name | `string` | `null` | no |
| <a name="input_session_timeout_hours"></a> [session\_timeout\_hours](#input\_session\_timeout\_hours) | The maximum session duration before a user reauthenticates. | `number` | `24` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to every applicable resource | `map(string)` | n/a | yes |
| <a name="input_transport_protocol"></a> [transport\_protocol](#input\_transport\_protocol) | The transport protocol to be used by the VPN session. | `string` | `"udp"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the target network VPC | `string` | n/a | yes |
| <a name="input_wait_for_certificate_issued"></a> [wait\_for\_certificate\_issued](#input\_wait\_for\_certificate\_issued) | Set to `off` to disable waiting for the certificate to be issued | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_vpn_arn"></a> [client\_vpn\_arn](#output\_client\_vpn\_arn) | The client vpn ARN |
| <a name="output_client_vpn_id"></a> [client\_vpn\_id](#output\_client\_vpn\_id) | The client vpn ID |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Versioning  
This project uses a `.version` file at the root of the repo which the pipeline reads from and does a git tag.  

When you intend to commit to `main`, you will need to increment this version. Once the project is merged,
the pipeline will kick off and tag the latest git commit.  

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
