# terraform-aws-module-template

## Overview

SourceFuse AWS Reference Architecture (ARC) Terraform module for managing _________.

## Usage

To see a full example, check out the [main.tf](./example/main.tf) file in the example folder.  

```hcl
module "this" {
  source = "git::https://github.com/sourcefuse/terraform-aws-refarch-<module_name>"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.11.0 |
| <a name="provider_aws.network-prod"></a> [aws.network-prod](#provider\_aws.network-prod) | 5.11.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ec2_client_vpn_endpoint.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_client_vpn_endpoint) | resource |
| [aws_iam_saml_provider.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_vpn_gateway.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpn_gateway) | resource |
| [aws_acm_certificate.cert](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_security_groups.security_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/security_groups) | data source |
| [aws_vpc.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_cidr"></a> [client\_cidr](#input\_client\_cidr) | The IPv4 address range, in CIDR notation, from which to assign client IP addresses. | `string` | `""` | no |
| <a name="input_client_vpn_split_tunnel"></a> [client\_vpn\_split\_tunnel](#input\_client\_vpn\_split\_tunnel) | Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false. | `bool` | `false` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | The name of the vpn client cloudwatch log group | `string` | `""` | no |
| <a name="input_cloudwatch_log_stream_name"></a> [cloudwatch\_log\_stream\_name](#input\_cloudwatch\_log\_stream\_name) | The name of the vpn client cloudwatch log stream | `string` | `""` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The list of dns server ip address | `list(string)` | <pre>[<br>  "1.1.1.1",<br>  "1.0.0.1"<br>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT' | `string` | `"dev"` | no |
| <a name="input_iam_saml_provider_name"></a> [iam\_saml\_provider\_name](#input\_iam\_saml\_provider\_name) | The name of the IAM SAML Provider name | `string` | `""` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for the resources. | `string` | `"hssc"` | no |
| <a name="input_saml_metadata_document_content"></a> [saml\_metadata\_document\_content](#input\_saml\_metadata\_document\_content) | The content of the saml metadata document | `string` | `"<?xml version=\"1.0\" encoding=\"UTF-8\"?><md:EntityDescriptor xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\" entityID=\"https://portal.sso.us-east-1.amazonaws.com/saml/assertion/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\">\n    <md:IDPSSODescriptor WantAuthnRequestsSigned=\"false\" protocolSupportEnumeration=\"urn:oasis:names:tc:SAML:2.0:protocol\">\n        <md:KeyDescriptor use=\"signing\">\n            <ds:KeyInfo xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\">\n                <ds:X509Data>\n                    <ds:X509Certificate>MIIDBzCCAe+gAwIBAgIFAIOiKqIwDQYJKoZIhvcNAQELBQAwRTEWMBQGA1UEAwwNYW1hem9uYXdzLmNvbTENMAsGA1UECwwESURBUzEPMA0GA1UECgwGQW1hem9uMQswCQYDVQQGEwJVUzAeFw0yMzA2MTMxNDI1NTJaFw0yODA2MTMxNDI1NTJaMEUxFjAUBgNVBAMMDWFtYXpvbmF3cy5jb20xDTALBgNVBAsMBElEQVMxDzANBgNVBAoMBkFtYXpvbjELMAkGA1UEBhMCVVMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC001jvCvyI6BLWVgDkR4KhEj8tl72jNMji05bGcBVzOQGc200p0dv8iuCN++DxJmwg2ds52qq5cCev9PrzzLnsuo1NLmerPdRjF4errEMOQOZ0jNNgUTLwoeuvd+aqSBXX4/LjO9+jJRhUeeYQsjwhHGu+ir3PSeV4sla++rQZtGjTj90wJpiOn8cDUUISsJHlvbgXzphg64TNTRfS1D4GBeC0amFabchTvXOpDj88QneiTQmzORYZYhNeAXEHqTUmBwntU8Pa8MTVR/O7NbKbRdDm8n/jYS4k9CSUjY3Dw8tCdEnoJVgAaInQYHtP7iDPzkvKV4tUJl2gINR6lW/dAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAEFkdZEj7PRC8Vt3qY8IU7TzGpZutYyJBv4Raoev3JizkpopZ3brbqWMHiiZ/RI+ynqI/AUjR/SaXfEEQ5LRclji0CLreF23opbV9QQfA+DMxGxl7uiUE4c0kZrhzUy8CjHVfXR92jCncULUSybGYLO0krE4+46pE/OpjtdmdMRQmCuItIahG2I8nxjeXMdo65byLScR22/MLv1FuyflXEcNMwuaPYXcDFlfvlWvGNaoqENeU85+v5nVtQiEtZ0Ou/ygVlfKg365XRLJntmVeuoyolGSOdY8fRsUnvQyJS3/YwpwyyzWm721NxjvIPjQdlfH/KPvCpBeQmN+fTviZhs=</ds:X509Certificate>\n                </ds:X509Data>\n            </ds:KeyInfo>\n        </md:KeyDescriptor>\n        <md:SingleLogoutService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Location=\"https://portal.sso.us-east-1.amazonaws.com/saml/logout/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"/>\n        <md:SingleLogoutService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect\" Location=\"https://portal.sso.us-east-1.amazonaws.com/saml/logout/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"/>\n        <md:NameIDFormat/>\n        <md:SingleSignOnService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Location=\"https://portal.sso.us-east-1.amazonaws.com/saml/assertion/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"/>\n        <md:SingleSignOnService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect\" Location=\"https://portal.sso.us-east-1.amazonaws.com/saml/assertion/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"/>\n    </md:IDPSSODescriptor>\n</md:EntityDescriptor>\n"` | no |
| <a name="input_transport_protocol"></a> [transport\_protocol](#input\_transport\_protocol) | The transport protocol to be used by the VPN session. | `string` | `"udp"` | no |

## Outputs

No outputs.
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
  go mod init github.com/sourcefuse/terraform-aws-refarch-<module_name>
  go get github.com/gruntwork-io/terratest/modules/terraform
  ```
- Now execute the test  
  ```sh
  go test -timeout  30m
  ```

## Authors

This project is authored by:
- SourceFuse
