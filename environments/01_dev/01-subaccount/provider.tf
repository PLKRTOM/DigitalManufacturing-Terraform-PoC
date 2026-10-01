# modules/provider.tf

terraform {
  required_version = ">= 1.5.0"

  # Określasz jedynie, z jakimi wersjami providera moduł jest kompatybilny
  required_providers {
    btp = {
      source  = "sap/btp"
      version = ">= 1.25.0, < 2.0.0"
    }
  }
}
