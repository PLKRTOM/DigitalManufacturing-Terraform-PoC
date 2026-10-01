module "btp_subaccount_dev" {
  source = "../../../modules/btp_connectivity"

  #  Variables from <environment>.auto.tfvars
  globalaccount           = "kioninformationmanagementservicesgmbh"
  subaccount_id           = var.subaccount_id
  s4hana_destination_name = var.s4hana_destination_name
  s4hana_url              = var.s4hana_url
  s4hana_client_id        = var.s4hana_client_id
  s4hana_client_secret    = var.s4hana_client_secret

}
