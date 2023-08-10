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
| <a name="module_self_signed_cert"></a> [self\_signed\_cert](#module\_self\_signed\_cert) | git::https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert.git | 1.3.0 |

## Resources

| Name | Type |
|------|------|
| [aws_ec2_client_vpn_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_iam_saml_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_security_group.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpn_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_authentication_options_active_directory_id"></a> [authentication\_options\_active\_directory\_id](#input\_authentication\_options\_active\_directory\_id) | The ID of the Active Directory to be used for authentication if type is directory-service-authentication. | `string` | `null` | no |
| <a name="input_authentication_options_root_certificate_chain_arn"></a> [authentication\_options\_root\_certificate\_chain\_arn](#input\_authentication\_options\_root\_certificate\_chain\_arn) | The ARN of the client certificate. The certificate must be signed by a certificate authority (CA) and it must be provisioned in AWS Certificate Manager (ACM). Only necessary when type is set to certificate-authentication. | `string` | `null` | no |
| <a name="input_authentication_options_saml_provider_arn"></a> [authentication\_options\_saml\_provider\_arn](#input\_authentication\_options\_saml\_provider\_arn) | The ARN of the IAM SAML identity provider if type is federated-authentication. | `string` | `null` | no |
| <a name="input_authentication_options_self_service_saml_provider_arn"></a> [authentication\_options\_self\_service\_saml\_provider\_arn](#input\_authentication\_options\_self\_service\_saml\_provider\_arn) | The ARN of the IAM SAML identity provider for the self service portal if type is federated-authentication. | `string` | `null` | no |
| <a name="input_authentication_options_type"></a> [authentication\_options\_type](#input\_authentication\_options\_type) | The type of client authentication to be used.<br>Specify certificate-authentication to use certificate-based authentication, directory-service-authentication to use Active Directory authentication,<br>or federated-authentication to use Federated Authentication via SAML 2.0. | `string` | `"federated-authentication"` | no |
| <a name="input_client_cidr"></a> [client\_cidr](#input\_client\_cidr) | The IPv4 address range, in CIDR notation, from which to assign client IP addresses. | `string` | n/a | yes |
| <a name="input_client_server_certificate_arn"></a> [client\_server\_certificate\_arn](#input\_client\_server\_certificate\_arn) | The ARN of the ACM server certificate. | `string` | `null` | no |
| <a name="input_client_server_transport_protocol"></a> [client\_server\_transport\_protocol](#input\_client\_server\_transport\_protocol) | The transport protocol to be used by the VPN session. | `string` | `"tcp"` | no |
| <a name="input_client_vpn_additional_security_group_ids"></a> [client\_vpn\_additional\_security\_group\_ids](#input\_client\_vpn\_additional\_security\_group\_ids) | Additional IDs of security groups to add to the target network. | `list(string)` | `[]` | no |
| <a name="input_client_vpn_egress_rules"></a> [client\_vpn\_egress\_rules](#input\_client\_vpn\_egress\_rules) | Egress rules for the security groups. | <pre>map(object({<br>    description       = optional(string)<br>    from_port         = number<br>    to_port           = number<br>    protocol          = string<br>    cidr_blocks       = optional(list(string))<br>    security_group_id = optional(list(string))<br>    ipv6_cidr_blocks  = optional(list(string))<br>  }))</pre> | `{}` | no |
| <a name="input_client_vpn_gateway_name"></a> [client\_vpn\_gateway\_name](#input\_client\_vpn\_gateway\_name) | The name of the client vpn gateway. | `string` | n/a | yes |
| <a name="input_client_vpn_ingress_rules"></a> [client\_vpn\_ingress\_rules](#input\_client\_vpn\_ingress\_rules) | Ingress rules for the security groups. | <pre>map(object({<br>    description       = optional(string)<br>    from_port         = number<br>    to_port           = number<br>    protocol          = string<br>    cidr_blocks       = optional(list(string))<br>    security_group_id = optional(list(string))<br>    ipv6_cidr_blocks  = optional(list(string))<br>    self              = optional(bool)<br>  }))</pre> | `{}` | no |
| <a name="input_client_vpn_log_options"></a> [client\_vpn\_log\_options](#input\_client\_vpn\_log\_options) | Whether logging is enabled and where to send the logs output. | <pre>object({<br>    enabled               = bool                   // Indicates whether connection logging is enabled<br>    cloudwatch_log_stream = optional(string, null) // The name of the vpn client cloudwatch log stream<br>    cloudwatch_log_group  = optional(string, null) // The name of the vpn client cloudwatch log group<br>  })</pre> | <pre>{<br>  "enabled": false<br>}</pre> | no |
| <a name="input_client_vpn_name"></a> [client\_vpn\_name](#input\_client\_vpn\_name) | The name of the client vpn | `string` | `"client-vpn-01"` | no |
| <a name="input_client_vpn_self_service_portal"></a> [client\_vpn\_self\_service\_portal](#input\_client\_vpn\_self\_service\_portal) | Specify whether to enable the self-service portal for the Client VPN endpoint. Values can be enabled or disabled. | `string` | `"disabled"` | no |
| <a name="input_client_vpn_split_tunnel"></a> [client\_vpn\_split\_tunnel](#input\_client\_vpn\_split\_tunnel) | Indicates whether split-tunnel is enabled on VPN endpoint. | `bool` | `true` | no |
| <a name="input_create_self_signed_server_cert"></a> [create\_self\_signed\_server\_cert](#input\_create\_self\_signed\_server\_cert) | Create a self signed certificate to use for the VPN server. | `bool` | `true` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The list of dns server ip address | `list(string)` | <pre>[<br>  "1.1.1.1",<br>  "1.0.0.1"<br>]</pre> | no |
| <a name="input_iam_saml_provider_enabled"></a> [iam\_saml\_provider\_enabled](#input\_iam\_saml\_provider\_enabled) | Enable the SAML provider for SSO login to Client VPN. If enabled, `var.iam_saml_provider_name` and `var.saml_metadata_document_content` must be set. | `bool` | `false` | no |
| <a name="input_iam_saml_provider_name"></a> [iam\_saml\_provider\_name](#input\_iam\_saml\_provider\_name) | The name of the IAM SAML Provider | `string` | `""` | no |
| <a name="input_saml_metadata_document_content"></a> [saml\_metadata\_document\_content](#input\_saml\_metadata\_document\_content) | The content of the saml metadata document | `string` | `null` | no |
| <a name="input_self_signed_server_cert_allowed_uses"></a> [self\_signed\_server\_cert\_allowed\_uses](#input\_self\_signed\_server\_cert\_allowed\_uses) | List of keywords each describing a use that is permitted for the issued certificate.<br>Must be one of of the values outlined in [self\_signed\_cert.allowed\_uses](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert#allowed_uses). | `list(string)` | <pre>[<br>  "key_encipherment",<br>  "digital_signature",<br>  "server_auth"<br>]</pre> | no |
| <a name="input_self_signed_server_cert_name"></a> [self\_signed\_server\_cert\_name](#input\_self\_signed\_server\_cert\_name) | Name to assign the Self-Signed certificate for the VPN Server. | `string` | `"client-vpn-server-self-signed-certificate"` | no |
| <a name="input_self_signed_server_cert_subject"></a> [self\_signed\_server\_cert\_subject](#input\_self\_signed\_server\_cert\_subject) | The subject configuration for the certificate.<br>This should be a map that is compatible with [tls\_cert\_request.subject](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/cert_request#subject). | `any` | `{}` | no |
| <a name="input_self_signed_server_cert_subject_alt_names"></a> [self\_signed\_server\_cert\_subject\_alt\_names](#input\_self\_signed\_server\_cert\_subject\_alt\_names) | The subject alternative name (SAN) configuration for the certificate. This configuration consists of several lists, each of which can also be set to `null` or `[]`.<br><br>`dns_names`: List of DNS names for which a certificate is being requested.<br>`ip_addresses`: List of IP addresses for which a certificate is being requested.<br>`uris`: List of URIs for which a certificate is being requested.<br><br>Defaults to no SANs. | <pre>object({<br>    dns_names    = optional(list(string), null)<br>    ip_addresses = optional(list(string), null)<br>    uris         = optional(list(string), null)<br>  })</pre> | `{}` | no |
| <a name="input_self_signed_server_cert_validity"></a> [self\_signed\_server\_cert\_validity](#input\_self\_signed\_server\_cert\_validity) | Validity settings for the issued certificate:<br><br>`duration_hours`: The number of hours from issuing the certificate until it becomes invalid.<br>`early_renewal_hours`: If set, the resource will consider the certificate to have expired the given number of hours before its actual expiry time (see: [self\_signed\_cert.early\_renewal\_hours](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/self_signed_cert#early_renewal_hours)).<br><br>Defaults to 10 years and no early renewal hours. | <pre>object({<br>    duration_hours      = number<br>    early_renewal_hours = number<br>  })</pre> | <pre>{<br>  "duration_hours": 87600,<br>  "early_renewal_hours": null<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Default tags to apply to every applicable resource | `map(string)` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | The ID of the target network VPC | `string` | n/a | yes |

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
