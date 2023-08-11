# terraform-aws-refarch-vpn example

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.12.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_self_signed_cert_ca"></a> [self\_signed\_cert\_ca](#module\_self\_signed\_cert\_ca) | git::https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert.git | 1.3.0 |
| <a name="module_self_signed_cert_root"></a> [self\_signed\_cert\_root](#module\_self\_signed\_cert\_root) | git::https://github.com/cloudposse/terraform-aws-ssm-tls-self-signed-cert.git | 1.3.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | git::https://github.com/sourcefuse/terraform-aws-refarch-tags.git | 1.2.1 |
| <a name="module_vpn"></a> [vpn](#module\_vpn) | ../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.ca_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment the resource belongs to. | `string` | `"poc"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to assign the resources | `string` | `"arc"` | no |
| <a name="input_private_subnet_names_override"></a> [private\_subnet\_names\_override](#input\_private\_subnet\_names\_override) | The name of the subnets to associate to the VPN. | `list(string)` | `[]` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project the vpn resource belongs to. | `string` | `"arc-example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_secret_path_format"></a> [secret\_path\_format](#input\_secret\_path\_format) | The path format to use when writing secrets to the certificate backend. | `string` | `"/%s.%s"` | no |
| <a name="input_vpc_name_override"></a> [vpc\_name\_override](#input\_vpc\_name\_override) | The name of the target network VPC. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
