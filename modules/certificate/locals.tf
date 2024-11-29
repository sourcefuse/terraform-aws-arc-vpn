locals {
  allowed_uses_map = {
    ca     = ["cert_signing", "crl_signing"]
    root   = ["key_encipherment", "digital_signature", "client_auth"]
    server = ["key_encipherment", "digital_signature", "server_auth"]
  }
}
