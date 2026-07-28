################################################################################
## shared
################################################################################
variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "namespace" {
  type        = string
  description = "Namespace to assign the resources"
  default     = "arc"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "poc"
}

variable "project_name" {
  type        = string
  description = "Project name used for tagging"
  default     = "arc-example"
}

################################################################################
## VPC / subnet lookup
################################################################################
variable "vpc_id" {
  type        = string
  description = "VPC ID override. If set, skips tag-based VPC lookup."
  default     = null
}

variable "vpc_name" {
  type        = string
  description = "VPC Name tag override."
  default     = null
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet ID override. If set, skips tag-based subnet lookup."
  default     = []
}

variable "subnet_names" {
  type        = list(string)
  description = "Subnet Name tag override."
  default     = []
}

################################################################################
## VPN
################################################################################
variable "client_cidr_block" {
  type        = string
  description = "Client CIDR block. Must not overlap with any VPC subnet."
  default     = null
}

variable "iam_saml_provider_name" {
  type        = string
  description = "Name of the IAM SAML provider."
  default     = "keycloak-client-vpn"
}

################################################################################
## Keycloak
################################################################################
variable "create_keycloak_realm" {
  type        = bool
  description = "Set to false if the realm already exists in Keycloak."
  default     = true
}

variable "keycloak_config" {
  description = "Keycloak connection and VPN user configuration."
  type = object({
    create            = optional(bool, true)
    url               = string
    realm             = string
    client_id         = optional(string, "admin-cli")
    username          = string
    password          = optional(string, null)
    ssm_password_path = optional(string, null)
    vpn_users = optional(map(object({
      email      = string
      first_name = string
      last_name  = string
    })), {})
  })

  validation {
    condition     = var.keycloak_config.password != null || var.keycloak_config.ssm_password_path != null
    error_message = "Either 'password' or 'ssm_password_path' must be provided in keycloak_config."
  }
}
