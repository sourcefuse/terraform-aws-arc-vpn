terraform {
  required_version = ">= 1.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 7.0"
    }
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 4.5"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }
}
