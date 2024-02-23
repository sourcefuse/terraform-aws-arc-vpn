# Terraform AWS ARC VPN Module Usage Guide

## Introduction

### Purpose of the Document

This document provides guidelines and instructions for users looking to implement Terraform ARC module for managing a AWS Client VPN.

#### What is AWS Client VPN ?
AWS Client VPN is a managed remote access VPN solution used by your remote workforce to securely access resources within both AWS and your on-premises network. Fully elastic, it automatically scales up, or down, based on demand.

### Module Overview

The [terraform-aws-arc-vpn](https://github.com/sourcefuse/terraform-aws-arc-vpn) The VPN setup allows users to securely connect to the AWS VPC from anywhere, using the created client VPN.

### Prerequisites

Before using this module, ensure you have the following:

- AWS credentials configured.
- Terraform installed.
- A working knowledge of AWS Client VPN

## Getting Started

### Module Source

To use the module in your Terraform configuration, include the following source block:

```tcl
module "client_vpn" {
  source  = "sourcefuse/arc-vpn/aws"
  version = "0.0.8"
  # insert the required variables here
}
```

### Integration with Existing Terraform Configurations

Integrate the module with your existing Terraform mono repo configuration, follow the steps below:

1. Create a new folder in `terraform/` named `client_vpn`.
2. Create the required files, see the [examples](https://github.com/sourcefuse/terraform-aws-arc-vpn/tree/main/examples/simple) to base off of.
3. Configure with your backend
  - Create the environment backend configuration file: `config.<environment>.hcl`
    - **region**: Where the backend resides
    - **key**: `<working_directory>/terraform.tfstate`
    - **bucket**: Bucket name where the terraform state will reside
    - **dynamodb_table**: Lock table so there are not duplicate tfplans in the mix
    - **encrypt**: Encrypt all traffic to and from the backend

### Required AWS Permissions

Ensure that the AWS credentials used to execute Terraform have the necessary permissions to create
 - Client VPN Endpoint
 - Virtual Private Gateway

## Module Configuration

### Input Variables

For a list of input variables, see the README [Inputs](https://github.com/sourcefuse/terraform-aws-arc-vpn?tab=readme-ov-file#inputs) section.

### Output Values

For a list of outputs, see the README [Outputs](https://github.com/sourcefuse/terraform-aws-arc-vpn?tab=readme-ov-file#outputs) section.

## Module Usage

### Basic Usage

For basic usage, see the [example](https://github.com/sourcefuse/terraform-aws-arc-vpn/tree/main/example) folder.

This example will create:

- Self-Signed Certificate Authority (CA) Creation: It creates a self-signed CA certificate using the cloudposse/terraform-aws-ssm-tls-self-signed-cert module. The certificate is stored in AWS SSM (Systems Manager).

- Self-Signed Root Certificate Creation: It creates a self-signed root certificate using the cloudposse/terraform-aws-ssm-tls-self-signed-cert module. This certificate is signed by the previously created CA certificate.

- VPN Setup: It uses the sourcefuse/arc-vpn/aws module to create a VPN setup. This includes:

	- Certificate-based authentication using the self-signed root certificate.

	- Authorize all groups to access the VPN.

	- Specifying the private subnets where the VPN endpoints will be created.

	- Specifying the target network CIDR block, which is the VPC's CIDR block.

	- Created a self-signed server certificate.

	- Setting up the client VPN with a specified client CIDR block, VPN name, and VPN gateway name.

The VPN setup allows users to securely connect to the AWS VPC from anywhere, using the created client VPN. The self-signed certificates are used to authenticate the users.

### How to create AWS Client VPN file
- Download and install AWS Client VPN Application [download](https://aws.amazon.com/vpn/client-vpn-download/)
- Download the AWS Client VPN Configuration File
	- Navigate to `VPC` > `Client VPN endpoints`
	- Select the endpoint and click `Download Client Configuration`
- Incase authentication is using certificate
	- Open the Client Configuration file in an editor.
	- Append the certificate data as show below to the configuration file
	```
	<cert>
		Copy from SSM PARAM self-signed-cert-ca.pem
	</cert>

	<key>
		Copy from SSM PARAM self-signed-cert-ca.key
	</key>
	```



### Tips and Recommendations

To authenticate the AWS Client VPN, integration with Active Directory (AD) is possible.

## Troubleshooting

### Reporting Issues

If you encounter a bug or issue, please report it on the [GitHub repository](https://github.com/sourcefuse/terraform-aws-arc-vpn/issues).

## Security Considerations

### AWS VPC

Understand the security considerations related to Client VPN when using this module.

### Best Practices for Client VPN

Follow best practices to ensure secure Client VPN.
[Client VPN Security on AWS](https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/security-best-practices.html)

## Contributing and Community Support

### Contributing Guidelines

Contribute to the module by following the guidelines outlined in the [CONTRIBUTING.md](https://github.com/sourcefuse/terraform-aws-arc-vpn/blob/main/CONTRIBUTING.md) file.

### Reporting Bugs and Issues

If you find a bug or issue, report it on the [GitHub repository](https://github.com/sourcefuse/terraform-aws-arc-vpn/issues).

## License

### License Information

This module is licensed under the Apache 2.0 license. Refer to the [LICENSE](https://github.com/sourcefuse/terraform-aws-arc-vpn/blob/main/LICENSE) file for more details.

### Open Source Contribution

Contribute to open source by using and enhancing this module. Your contributions are welcome!
