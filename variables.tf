################################################################
## shared
################################################################
variable "environment" {
  type        = string
  default     = "dev"
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
}

variable "namespace" {
  type        = string
  default     = ""
  description = "Namespace for the resources."
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
  default     = "\u003c?xml version=\"1.0\" encoding=\"UTF-8\"?\u003e\u003cmd:EntityDescriptor xmlns:md=\"urn:oasis:names:tc:SAML:2.0:metadata\" entityID=\"https://portal.sso.us-east-1.amazonaws.com/saml/assertion/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"\u003e\n    \u003cmd:IDPSSODescriptor WantAuthnRequestsSigned=\"false\" protocolSupportEnumeration=\"urn:oasis:names:tc:SAML:2.0:protocol\"\u003e\n        \u003cmd:KeyDescriptor use=\"signing\"\u003e\n            \u003cds:KeyInfo xmlns:ds=\"http://www.w3.org/2000/09/xmldsig#\"\u003e\n                \u003cds:X509Data\u003e\n                    \u003cds:X509Certificate\u003eMIIDBzCCAe+gAwIBAgIFAIOiKqIwDQYJKoZIhvcNAQELBQAwRTEWMBQGA1UEAwwNYW1hem9uYXdzLmNvbTENMAsGA1UECwwESURBUzEPMA0GA1UECgwGQW1hem9uMQswCQYDVQQGEwJVUzAeFw0yMzA2MTMxNDI1NTJaFw0yODA2MTMxNDI1NTJaMEUxFjAUBgNVBAMMDWFtYXpvbmF3cy5jb20xDTALBgNVBAsMBElEQVMxDzANBgNVBAoMBkFtYXpvbjELMAkGA1UEBhMCVVMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC001jvCvyI6BLWVgDkR4KhEj8tl72jNMji05bGcBVzOQGc200p0dv8iuCN++DxJmwg2ds52qq5cCev9PrzzLnsuo1NLmerPdRjF4errEMOQOZ0jNNgUTLwoeuvd+aqSBXX4/LjO9+jJRhUeeYQsjwhHGu+ir3PSeV4sla++rQZtGjTj90wJpiOn8cDUUISsJHlvbgXzphg64TNTRfS1D4GBeC0amFabchTvXOpDj88QneiTQmzORYZYhNeAXEHqTUmBwntU8Pa8MTVR/O7NbKbRdDm8n/jYS4k9CSUjY3Dw8tCdEnoJVgAaInQYHtP7iDPzkvKV4tUJl2gINR6lW/dAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAEFkdZEj7PRC8Vt3qY8IU7TzGpZutYyJBv4Raoev3JizkpopZ3brbqWMHiiZ/RI+ynqI/AUjR/SaXfEEQ5LRclji0CLreF23opbV9QQfA+DMxGxl7uiUE4c0kZrhzUy8CjHVfXR92jCncULUSybGYLO0krE4+46pE/OpjtdmdMRQmCuItIahG2I8nxjeXMdo65byLScR22/MLv1FuyflXEcNMwuaPYXcDFlfvlWvGNaoqENeU85+v5nVtQiEtZ0Ou/ygVlfKg365XRLJntmVeuoyolGSOdY8fRsUnvQyJS3/YwpwyyzWm721NxjvIPjQdlfH/KPvCpBeQmN+fTviZhs=\u003c/ds:X509Certificate\u003e\n                \u003c/ds:X509Data\u003e\n            \u003c/ds:KeyInfo\u003e\n        \u003c/md:KeyDescriptor\u003e\n        \u003cmd:SingleLogoutService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Location=\"https://portal.sso.us-east-1.amazonaws.com/saml/logout/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"/\u003e\n        \u003cmd:SingleLogoutService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect\" Location=\"https://portal.sso.us-east-1.amazonaws.com/saml/logout/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"/\u003e\n        \u003cmd:NameIDFormat/\u003e\n        \u003cmd:SingleSignOnService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST\" Location=\"https://portal.sso.us-east-1.amazonaws.com/saml/assertion/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"/\u003e\n        \u003cmd:SingleSignOnService Binding=\"urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect\" Location=\"https://portal.sso.us-east-1.amazonaws.com/saml/assertion/MTkyNTMwMjE4MDg1X2lucy1lNDJiMDkxZDI2MTllZjNl\"/\u003e\n    \u003c/md:IDPSSODescriptor\u003e\n\u003c/md:EntityDescriptor\u003e\n"
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
