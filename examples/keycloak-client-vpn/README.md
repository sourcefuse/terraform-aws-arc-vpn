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
