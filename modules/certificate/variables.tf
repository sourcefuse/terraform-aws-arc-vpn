variable "environment" {
  type        = string
  description = "The deployment environment (e.g., dev, staging, prod)."
}

variable "namespace" {
  type        = string
  description = "The namespace to group resources (e.g., project name or application name)."
}

variable "name" {
  type        = string
  description = "(optional) describe your variable"
}

variable "type" {
  type        = string
  description = "Type of Certificate. Valid values: ca, server, root."

  validation {
    condition     = contains(["ca", "server", "root"], var.type)
    error_message = "Invalid value for 'type'. Must be one of: 'ca', 'server', or 'root'."
  }
}

variable "allowed_uses" {
  type        = list(string)
  description = "List of allowed uses for the certificate. Valid values: key_encipherment, digital_signature, server_auth, client_auth."
  default     = []
}

variable "import_to_acm" {
  type        = bool
  description = "(optional) Whether to import the certificate to ACM"
  default     = false
}

variable "store_in_ssm" {
  type        = bool
  description = "(optional) Whether to store the certificates in SSM"
  default     = true
}

variable "store_it_locally" {
  type        = bool
  description = "(optional) Whether to save the certificate locally"
  default     = true
}

variable "tags" {
  type        = map(string)
  description = "Tags for resources"
  default     = {}
}

variable "subject" {
  type = object({
    common_name  = string
    organization = string
  })

  description = "Subject information for the certificate."

  validation {
    condition     = strcontains(var.subject.common_name, ".") && length(var.subject.organization) > 0
    error_message = "The 'common_name' must contain a '.' character, and 'organization' must not be empty."
  }
}


variable "validity_period_hours" {
  type        = number
  description = "The validity period for the certificate in hours."

  validation {
    condition     = var.validity_period_hours > 0
    error_message = "The validity period must be a positive number."
  }

  default = 43800 # Default to 5 years (43,800 hours)
}

variable "ca_cert_pem" {
  type        = string
  description = "(optional) CA certificate, required to sign root or server certificate"
  default     = null
}

variable "ca_private_key_pem" {
  type        = string
  description = "(optional) Private Key of CA"
  default     = null
}
