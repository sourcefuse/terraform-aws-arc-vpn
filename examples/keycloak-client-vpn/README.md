# Keycloak Client VPN Example

This example deploys an AWS Client VPN endpoint that authenticates users via **Keycloak SAML 2.0 federated authentication**. Users log in with their Keycloak credentials — no client certificates are distributed.

## Architecture

```
Developer Laptop
  └── AWS VPN Client
        │
        ├─(1) Opens browser → Keycloak login page
        ├─(2) User authenticates with Keycloak credentials
        ├─(3) Keycloak returns SAML assertion
        ├─(4) AWS validates assertion against IAM SAML provider
        └─(5) VPN tunnel established → access to private subnets
```

**Resources created by this example:**

- TLS CA certificate (ACM + SSM)
- TLS server certificate with SAN (ACM + SSM)
- IAM SAML provider (backed by Keycloak metadata)
- AWS Client VPN endpoint (`federated-authentication`)
- VPN security group, subnet associations, authorization rule
- Keycloak SAML client (`urn:amazon:webservices:clientvpn`)
- Keycloak email attribute mapper
- Keycloak realm assertion lifespan fix (5 min)
- VPN users in Keycloak with passwords stored in SSM

## Prerequisites

| Tool | Version |
|------|---------|
| Terraform | >= 1.3 |
| AWS CLI | >= 2.x |
| Keycloak | >= 21.x |
| AWS VPN Client | >= 3.x ([download](https://aws.amazon.com/vpn/client-vpn-download/)) |
| curl + python3 | any (used by null_resource for realm settings) |

- An existing VPC (tagged or provide ID directly)
- Private subnets (tagged or provide IDs directly)
- Keycloak instance reachable from the internet

## Quick Start

```bash
# 1. Copy example vars
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 2. Export your Keycloak IdP metadata
curl -o metadata/keycloak-saml.xml \
  https://keycloak.example.com/auth/realms/myrealm/protocol/saml/descriptor

# 3. Deploy
terraform init
terraform apply
```

## Keycloak Setup

Terraform automatically creates the SAML client in Keycloak. You only need to ensure:

1. The Keycloak realm exists
2. The metadata file is populated (step 2 above)

If the realm is shared with IAM Identity Center, Terraform manages only the VPN SAML client — it does not modify the realm itself (except the assertion lifespan via API).

### Manual Keycloak client (alternative)

If you prefer to create the client manually instead of via Terraform, set `vpn_users = {}` and create a SAML client with:

| Field | Value |
|-------|-------|
| Client ID | `urn:amazon:webservices:clientvpn` |
| Valid Redirect URIs | `http://127.0.0.1:35001` |
| | `https://self-service.clientvpn.amazonaws.com/api/auth/sso/saml` |
| Sign documents | ON |
| Sign assertions | ON |
| Force POST binding | ON |
| Name ID format | email |
| Attribute mapper | `email` → `saml-user-attribute-mapper` → attribute name `email` |

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `region` | AWS region | `us-east-1` |
| `namespace` | Resource namespace | `arc` |
| `environment` | Environment name | `poc` |
| `project_name` | Project name for tagging | `arc-example` |
| `vpc_id` | VPC ID (skips tag lookup) | `null` |
| `vpc_name` | VPC Name tag override | `null` |
| `subnet_ids` | Subnet IDs (skips tag lookup) | `[]` |
| `subnet_names` | Subnet Name tag overrides | `[]` |
| `client_cidr_block` | VPN client CIDR (must not overlap subnets) | auto |
| `iam_saml_provider_name` | IAM SAML provider name | `keycloak-client-vpn` |
| `keycloak_url` | Keycloak base URL including `/auth` | required |
| `keycloak_realm` | Keycloak realm | `master` |
| `keycloak_username` | Keycloak admin username | required |
| `keycloak_password` | Keycloak admin password | required |
| `vpn_users` | Map of VPN users to create | `{}` |

## Outputs

| Name | Description |
|------|-------------|
| `client_vpn_arn` | Client VPN endpoint ARN |
| `client_vpn_id` | Client VPN endpoint ID |
| `server_certificate` | Server certificate ARN (ACM) |

## Connecting

1. Download the VPN config:
   ```bash
   aws ec2 export-client-vpn-client-configuration \
     --client-vpn-endpoint-id <endpoint-id> \
     --query "ClientConfiguration" --output text > vpn.ovpn
   ```
2. Open **AWS VPN Client** → **Add Profile** → select `vpn.ovpn`
3. Click **Connect** → browser opens Keycloak → login
4. VPN connects ✅

## Retrieve a user's initial password

```bash
aws ssm get-parameter \
  --name "/arc-vpn/<realm>/users/<email_at_domain>/password" \
  --with-decryption --query "Parameter.Value" --output text
```

## Troubleshooting

| Error | Cause | Fix |
|-------|-------|-----|
| `The credentials received were incorrect` | Missing SAML attribute | Ensure `email-attr` mapper exists in Keycloak client |
| `The credentials received were incorrect` | Assertion expired | Ensure `accessCodeLifespan` >= 300s in realm |
| Browser doesn't open | Wrong VPN client | Use AWS VPN Client, not OpenVPN Connect |
| `409 Conflict` on realm | Realm already exists | `terraform import 'keycloak_realm.aws_sso_settings' '<realm>'` |
| `409 Conflict` on user | User already exists in Keycloak | `terraform import 'keycloak_user.vpn_user["key"]' '<realm>/<uuid>'` |
| Subnet CIDR overlap | `client_cidr_block` overlaps a subnet | Set `client_cidr_block` to a non-overlapping range |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 7.0 |
| <a name="requirement_http"></a> [http](#requirement\_http) | >= 3.0 |
| <a name="requirement_keycloak"></a> [keycloak](#requirement\_keycloak) | >= 4.5 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_http"></a> [http](#provider\_http) | 3.6.0 |
| <a name="provider_keycloak"></a> [keycloak](#provider\_keycloak) | 5.7.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ca"></a> [ca](#module\_ca) | ../../modules/certificate | n/a |
| <a name="module_tags"></a> [tags](#module\_tags) | sourcefuse/arc-tags/aws | 1.2.3 |
| <a name="module_vpn"></a> [vpn](#module\_vpn) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssm_parameter.keycloak_metadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.vpn_user_password](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [keycloak_generic_protocol_mapper.email_attr](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/generic_protocol_mapper) | resource |
| [keycloak_realm.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/realm) | resource |
| [keycloak_saml_client.this](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/saml_client) | resource |
| [keycloak_user.vpn_user](https://registry.terraform.io/providers/keycloak/keycloak/latest/docs/resources/user) | resource |
| [null_resource.realm_lifespan](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.remove_role_list_scope](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.vpn_user](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [aws_ssm_parameter.keycloak_metadata](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssm_parameter) | data source |
| [aws_subnets.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets) | data source |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |
| [http_http.keycloak_metadata](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_cidr_block"></a> [client\_cidr\_block](#input\_client\_cidr\_block) | Client CIDR block. Must not overlap with any VPC subnet. | `string` | `null` | no |
| <a name="input_create_keycloak_realm"></a> [create\_keycloak\_realm](#input\_create\_keycloak\_realm) | Set to false if the realm already exists in Keycloak. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"poc"` | no |
| <a name="input_iam_saml_provider_name"></a> [iam\_saml\_provider\_name](#input\_iam\_saml\_provider\_name) | Name of the IAM SAML provider. | `string` | `"keycloak-client-vpn"` | no |
| <a name="input_keycloak_config"></a> [keycloak\_config](#input\_keycloak\_config) | Keycloak connection and VPN user configuration. | <pre>object({<br/>    create    = optional(bool, true)<br/>    url       = string<br/>    realm     = string<br/>    client_id = optional(string, "admin-cli")<br/>    username  = string<br/>    password  = string<br/>    vpn_users = optional(map(object({<br/>      email      = string<br/>      first_name = string<br/>      last_name  = string<br/>    })), {})<br/>  })</pre> | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace to assign the resources | `string` | `"arc"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name used for tagging | `string` | `"arc-example"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | Subnet ID override. If set, skips tag-based subnet lookup. | `list(string)` | `[]` | no |
| <a name="input_subnet_names"></a> [subnet\_names](#input\_subnet\_names) | Subnet Name tag override. | `list(string)` | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID override. If set, skips tag-based VPC lookup. | `string` | `null` | no |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | VPC Name tag override. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_vpn_arn"></a> [client\_vpn\_arn](#output\_client\_vpn\_arn) | The Keycloak-integrated Client VPN ARN |
| <a name="output_client_vpn_id"></a> [client\_vpn\_id](#output\_client\_vpn\_id) | The Keycloak-integrated Client VPN ID |
| <a name="output_keycloak_metadata_ssm_path"></a> [keycloak\_metadata\_ssm\_path](#output\_keycloak\_metadata\_ssm\_path) | SSM parameter path storing the patched Keycloak SAML metadata XML |
| <a name="output_saml_client_client_id"></a> [saml\_client\_client\_id](#output\_saml\_client\_client\_id) | SAML client\_id (urn:amazon:webservices:clientvpn) |
| <a name="output_saml_client_id"></a> [saml\_client\_id](#output\_saml\_client\_id) | Keycloak internal UUID of the VPN SAML client |
| <a name="output_server_certificate"></a> [server\_certificate](#output\_server\_certificate) | Server certificate ARN (ACM) |
| <a name="output_vpn_user_ssm_paths"></a> [vpn\_user\_ssm\_paths](#output\_vpn\_user\_ssm\_paths) | Map of user key to SSM parameter path containing the initial password |
<!-- END_TF_DOCS -->
