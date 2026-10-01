module "btp_subaccount_dev" {
  source = "../../../modules/btp_connectivity"

  #  Variables from <environment>.auto.tfvars
  globalaccount = "kioninformationmanagementservicesgmbh"
  subaccount_id = var.subaccount_id
  destinations  = var.destinations
}
