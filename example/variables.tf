################################################################################
## shared
################################################################################
variable "tags" {
  type        = map(string)
  description = "Default tags to apply to every applicable resource"
}

variable "vpc_id" {
  type        = string
  description = "The id of the target network VPC"
}

################################################################################
## vpn
################################################################################
variable "client_vpn_cidr" {
  type        = string
  description = "The IPv4 address range, in CIDR notation, from which to assign client IP addresses. The CIDR block should be /22 or greater"
}

variable "client_authentication_type" {
  type        = string
  description = "Set to one of these applicable options: `federated-authentication`, `certificate-authentication` or `directory-service-authentication`"
  default     = "certificate-authentication"
}

variable "connection_log_enabled" {
  type        = bool
  description = "Set to `false` if you do not want client vpn connection log enabled"
  default     = false
}

variable "saml_provider_arn" {
  type        = string
  description = "The arn of the IAM SAML Provider name"
  default     = null
}

variable "self_service_saml_provider_arn" {
  type        = string
  description = "The arn of the IAM self service SAML Provider name"
  default     = null
}

variable "active_directory_id" {
  type        = string
  description = "The active directory id for client vpn authentication"
  default     = null
}

variable "root_certificate_chain_arn" {
  type        = string
  description = "The arn of the client vpn authentication root certificate"
  default     = null
}

variable "client_vpn_server_certificate_arn" {
  type        = string
  description = "The arn of the client vpn server certificate"
}

variable "self_service_portal_settings" {
  type        = string
  description = "Set to `enabled` if self service portal is needed"
  default     = "disabled"
}

variable "session_timeout_hours" {
  type        = number
  description = "The maximum session duration before a user reauthenticates."
  default     = 24
}

variable "authorize_all_groups_for_client_vpn" {
  type        = bool
  description = "Set to `true` to authorize all groups to access the target network"
  default     = true
}

variable "transport_protocol" {
  type        = string
  description = "The transport protocol to be used by the VPN session."
  default     = "udp"
}

variable "client_vpn_additional_security_group_ids" {
  type        = list(string)
  description = "The ids of additional securiity groups to attach to the target network"
  default     = []
}

variable "client_vpn_split_tunnel" {
  default     = false
  type        = bool
  description = "Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false."
}

variable "cloudwatch_log_group_name" {
  default     = "client-vpn-log-group"
  type        = string
  description = "The name of the vpn client cloudwatch log group"
}

variable "cloudwatch_log_stream_name" {
  default     = "client-vpn-log-stream"
  type        = string
  description = "The name of the vpn client cloudwatch log stream"
}

variable "dns_servers" {
  type        = list(string)
  description = "The list of dns server ip address"
  default = [
    "1.1.1.1",
    "1.0.0.1"
  ]
}

variable "client_vpn_name" {
  type        = string
  description = "The name of the client vpn"
  default     = "client-vpn"
}

variable "client_vpn_gateway_name" {
  type        = string
  description = "The name of the client vpn gateway"
  default     = "client-vpn-gw"
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    description = string
    cidr_blocks = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = []
}

variable "egress_rules" {
  description = "Default list of egress rules"
  type = list(object({
    description = string
    cidr_blocks = string
    from_port   = number
    to_port     = number
    protocol    = string
  }))
  default = []
}
