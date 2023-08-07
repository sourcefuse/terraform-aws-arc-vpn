################################################################################
## shared
################################################################################
variable "tags" {
  type        = map(string)
  description = "Default tags to apply to every applicable resource"
}

################################################################################
## vpn
################################################################################
variable "client_cidr" {
  type        = string
  description = "The IPv4 address range, in CIDR notation, from which to assign client IP addresses."
  default     = ""
}

variable "iam_saml_provider_name" {
  type        = string
  description = "The name of the IAM SAML Provider name"
  default     = ""
}

variable "transport_protocol" {
  type        = string
  description = "The transport protocol to be used by the VPN session."
  default     = "udp"
}

variable "client_vpn_split_tunnel" {
  default     = false
  type        = bool
  description = "Indicates whether split-tunnel is enabled on VPN endpoint. Default value is false."
}

variable "saml_metadata_document_content" {
  default     = null
  type        = string
  description = "The content of the saml metadata document"
}

variable "cloudwatch_log_group_name" {
  default     = ""
  type        = string
  description = "The name of the vpn client cloudwatch log group"
}

variable "cloudwatch_log_stream_name" {
  default     = ""
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
  default     = "client-vpn-01"
}

variable "client_vpn_gateway_name" {
  type        = string
  description = "The name of the client vpn gateway"
  default     = "client-vpn-gw"
}
