terraform {
  required_providers {
    btp = {
      source  = "sap/btp"
      version = "~> 1.22.0"
    }
  }
}

provider "btp" {
  globalaccount = var.globalaccount
  # Rely on BTP_USERNAME/BTP_PASSWORD environment variables or OIDC in CI/CD
  # Avoid hardcoding credentials.
  idp      = var.idp
  username = var.username
  password = var.password
}
