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

################################################################################
## lookups
################################################################################
variable "vpc_name_override" {
  type        = string
  description = "The name of the target network VPC."
  default     = null
}

variable "private_subnet_names_override" {
  type        = list(string)
  description = "The name of the subnets to associate to the VPN."
  default     = []
}

################################################################################
## certs
################################################################################
variable "secret_path_format" {
  description = "The path format to use when writing secrets to the certificate backend."
  type        = string
  default     = "/%s.%s"

  validation {
    condition     = can(substr(var.secret_path_format, 0, 1) == "/")
    error_message = "The secret path format must contain a leading slash."
  }
}

################################################################################
## vpn
################################################################################
variable "environment" {
  description = "Name of the environment the resource belongs to."
  type        = string
  default     = "poc"
}

variable "project_name" {
  description = "Name of the project the vpn resource belongs to."
  type        = string
  default     = "arc-example"
}
