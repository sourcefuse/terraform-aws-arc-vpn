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
| <a name="module_tags"></a> [tags](#module\_tags) | git::https://github.com/sourcefuse/terraform-aws-refarch-tags.git | 1.2.1 |
| <a name="module_vpn"></a> [vpn](#module\_vpn) | ../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment the resource belongs to. | `string` | `"poc"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to assign the resources | `string` | `"arc"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project the vpn resource belongs to. | `string` | `"arc-example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | The name of the target network VPC. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
