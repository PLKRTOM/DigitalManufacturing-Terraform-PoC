module "btp_subaccount_dev" {
  source = "../../modules"

  # Przekazanie wartości ze zmiennych środowiskowych (wczytanych z dev.auto.tfvars)
  tenant = "00"
}
