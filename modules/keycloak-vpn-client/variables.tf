variable "keycloak_url" {
  type        = string
  description = "Base URL of the Keycloak server including /auth (e.g. https://keycloak.example.com/auth)"
}

variable "keycloak_client_id" {
  type        = string
  description = "Keycloak admin client ID used to obtain an access token"
  default     = "admin-cli"
}

variable "keycloak_username" {
  type        = string
  description = "Keycloak admin username"
  sensitive   = true
}

variable "keycloak_password" {
  type        = string
  description = "Keycloak admin password"
  sensitive   = true
}

variable "keycloak_realm" {
  type        = string
  description = "Keycloak realm to create the VPN SAML client in"
}

variable "vpn_users" {
  description = "Map of VPN users to create in Keycloak. Passwords are auto-generated and stored in SSM."
  type = map(object({
    email      = string
    first_name = string
    last_name  = string
  }))
  default = {}
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to AWS resources created by this module"
  default     = {}
}
