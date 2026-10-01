terraform {
  required_providers {
    cloudfoundry = {
      source  = "cloudfoundry/cloudfoundry"
      version = "~> 1.17.0"
    }
  }

  backend "local" {
    path = ".tfstate/terraform.tfstate"
  }
}

provider "cloudfoundry" {
  api_url = var.cf_api_url
}
